// Copyright (c) 2020 CloudMakers, s. r. o. & Rumen G.Bogdanovski
// All rights reserved.
//
// You can use this software under the terms of 'INDIGO Astronomy
// open-source license' (see LICENSE.md).
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHORS 'AS IS' AND ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// version history
// 2.0 by Peter Polakovic <peter.polakovic@cloudmakers.eu>
//      & Rumen G.Bogdanovski <rumenastro@gmail.com>

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>

#include <indigo/indigo_bus.h>
#include <indigo/indigo_client.h>
#include <indigo/indigo_client_xml.h>

//
//  myClient.c
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-23.
//

#include "myClient.h"

static int device_pid;
static bool connected = false;
static int count = 10;
static int img_count = 1;

#define CCD_SIMULATOR "CCD Guider Simulator @ indigosky"

static indigo_result client_attach(indigo_client *client) {
    indigo_log("attached to INDI bus...");
    indigo_enumerate_properties(client, &INDIGO_ALL_PROPERTIES);
    return INDIGO_OK;
}

static indigo_result client_define_property(indigo_client *client, indigo_device *device, indigo_property *property, const char *message) {
    indigo_log("%s %s defined...", property->device, property->name);
    if (strcmp(property->device, CCD_SIMULATOR))
        return INDIGO_OK;
    if (!strcmp(property->name, CONNECTION_PROPERTY_NAME)) {
        indigo_device_connect(client, property->device);
        return INDIGO_OK;
    }
    if (!strcmp(property->name, "FILE_NAME")) {
        char value[1024] = { 0 };
        static const char * items[] = { "PATH" };
        static const char *values[1];
        values[0] = value;
        for (int i = 0 ; i < 1023; i++)
            value[i] = '0' + i % 10;
        indigo_change_text_property(client, CCD_SIMULATOR, "FILE_NAME", 1, items, values);
    }
    if (!strcmp(property->name, CCD_IMAGE_PROPERTY_NAME)) {
        if (device->version >= INDIGO_VERSION_2_0)
            indigo_enable_blob(client, property, INDIGO_ENABLE_BLOB_URL);
        else
            indigo_enable_blob(client, property, INDIGO_ENABLE_BLOB_ALSO);
    }
    if (!strcmp(property->name, CCD_IMAGE_FORMAT_PROPERTY_NAME)) {
        static const char * items[] = { CCD_IMAGE_FORMAT_JPEG_ITEM_NAME };
        static bool values[] = { true };
        indigo_change_switch_property(client, CCD_SIMULATOR, CCD_IMAGE_FORMAT_PROPERTY_NAME, 1, items, values);
    }
    return INDIGO_OK;
}

static indigo_result client_update_property(indigo_client *client, indigo_device *device, indigo_property *property, const char *message) {
    if (strcmp(property->device, CCD_SIMULATOR))
        return INDIGO_OK;
    if (!strcmp(property->name, CONNECTION_PROPERTY_NAME) && property->state == INDIGO_OK_STATE) {
        indigo_log("%s %s updated...", property->device, property->name);
        if (indigo_get_switch(property, CONNECTION_CONNECTED_ITEM_NAME)) {
//            if (!connected) {
                connected = true;
                indigo_log("connected...");
                static const char * items[] = { CCD_STREAMING_COUNT_ITEM_NAME };
                static double values[] = { -1 };
                indigo_change_number_property(client, property->device, CCD_STREAMING_PROPERTY_NAME, 1, items, values);
//            }
        } else {
//            if (connected) {
                indigo_log("disconnected...");
                connected = false;
//            }
        }
        return INDIGO_OK;
    }
    if (!strcmp(property->name, CCD_IMAGE_PROPERTY_NAME) && property->state == INDIGO_OK_STATE) {
        indigo_log("%s %s updated...", property->device, property->name);
        /* URL blob transfer is available only in client - server setup.
           This will never be called in case of a client loading a driver. */
        if (*property->items[0].blob.url && indigo_populate_http_blob_item(&property->items[0]))
            indigo_log("image URL received (%s, %d bytes)...", property->items[0].blob.url, property->items[0].blob.size);

        if (property->items[0].blob.value) {
            char name[32];
            sprintf(name, "img_%02d.jpg", img_count);
            FILE *f = fopen(name, "wb");
            if (f) {
                if (fwrite(property->items[0].blob.value, property->items[0].blob.size, 1, f)) {
                    indigo_log("image (%d bytes) saved to %s...", property->items[0].blob.size, name);
                } else {
                    indigo_log("image file write failed!", name);
                }
            } else {
                indigo_log("image file open failed!", name);
            }
            fclose(f);
            /* In case we have URL BLOB transfer we need to release the blob ourselves */
            if (*property->items[0].blob.url) {
                free(property->items[0].blob.value);
                property->items[0].blob.value = NULL;
            }
        }
    }
    if (!strcmp(property->name, CCD_EXPOSURE_PROPERTY_NAME)) {
        indigo_log("%s %s updated...", property->device, property->name);
        if (property->state == INDIGO_BUSY_STATE) {
            indigo_log("exposure %gs...", property->items[0].number.value);
        } else if (property->state == INDIGO_OK_STATE) {
            indigo_log("exposure done...");
        }
        return INDIGO_OK;
    }
    return INDIGO_OK;
}

static indigo_result client_send_message(indigo_client *client, indigo_device *device, indigo_property *property, const char *message) {
    indigo_log("%s received %s %s message: %s", client, property->device, property->name, message);
    return INDIGO_OK;
}

static indigo_result client_detach(indigo_client *client) {
    indigo_log("detached from INDI bus...");
    kill(device_pid, SIGKILL);
    exit(0);
    return INDIGO_OK;
}

static indigo_client client = {
    "MyClient", false, NULL, INDIGO_OK, INDIGO_VERSION_CURRENT, NULL,
    client_attach,
    client_define_property,
    client_update_property,
    client_send_message,
    NULL,
    client_detach
};

int myClient(int argc, const char ** argv, bool *isCancelled) {
    indigo_main_argc = argc;
    indigo_main_argv = argv;
    int input[2], output[2];
    if (pipe(input) < 0 || pipe(output) < 0) {
        indigo_log("Can't create local pipe for device (%s)", strerror(errno));
        return 0;
    }
    device_pid = fork();
    if (device_pid == 0) {
        close(0);
        dup2(output[0], 0);
        close(1);
        dup2(input[1], 1);
        execl("../build/drivers/indigo_ccd_simulator", "indigo_ccd_simulator", NULL);
    } else {
        indigo_log("Hello from %s... waiting for 10 seconds...", "Polar Align Aid");
        close(input[1]);
        close(output[0]);
        indigo_set_log_level(INDIGO_LOG_DEBUG);
        indigo_start();
        indigo_attach_client(&client);
        /* We want to connect to a remote indigo host indigosky.local:7624 */
        indigo_server_entry *server;
        indigo_connect_server("indigosky", "indigosky.local", 7624, &server);
        int i = count;
        while ((connected == false) && (i !=0)) { // timeout after
            indigo_log("waiting for connection to device... ");
            indigo_usleep(ONE_SECOND_DELAY);
            i--;
        }
//        for (i=0;i<count;i++) {
//            indigo_log("connected is %s...", connected ? "true" : "false");
//            indigo_usleep(ONE_SECOND_DELAY);
//
//        }
        while (*isCancelled == false){
            indigo_log("waiting for cancel signal...");
            indigo_log("isCancelled is %d", *isCancelled);
            indigo_log("connected is %s...", connected ? "true" : "false");
            indigo_usleep(ONE_SECOND_DELAY);
        }
        while (connected == true) {
            static const char * items[] = { CCD_ABORT_EXPOSURE_ITEM_NAME };
            static bool values[] = { true };
            indigo_log("aborting exposure... ");
            indigo_change_switch_property(&client, CCD_SIMULATOR, CCD_ABORT_EXPOSURE_PROPERTY_NAME, 1, items, values);
            indigo_log("disconnecting... ");
            indigo_device_disconnect(&client, CCD_SIMULATOR);
            indigo_usleep(ONE_SECOND_DELAY);
        }
        indigo_disconnect_server(server);
        indigo_log("stopping from main");
        indigo_stop();
    }
    return 0;
}
