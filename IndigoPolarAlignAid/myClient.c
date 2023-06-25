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
//                indigo_item item[] = { CCD_UPLOAD_MODE_CLIENT_ITEM_NAME };
//                static bool value = true;
//                indigo_set_switch(property, item, value);
                static const char * items[] = { CCD_EXPOSURE_ITEM_NAME };
                static double values[] = { 3.0 };
                indigo_change_number_property(client, property->device, CCD_EXPOSURE_PROPERTY_NAME, 1, items, values);
//            }
        } else {
//            if (connected) {
                indigo_log("disconnected...");
//                indigo_log("stopping from client_update_property");
//                indigo_stop();
                connected = false;
//            }
        }
        return INDIGO_OK;
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
    if (!strcmp(property->name, CCD_IMAGE_PROPERTY_NAME)) {
        indigo_log("%s %s updated...", property->device, property->name);
        if (property->state == INDIGO_OK_STATE) {
            indigo_log("image received (%d bytes)...", property->items[0].blob.size);
            indigo_device_disconnect(client, property->device);
        }
        return INDIGO_OK;
    }
    return INDIGO_OK;
}

static indigo_result client_send_message(indigo_client *client, indigo_device *device, indigo_property *property, const char *message) {
    indigo_log("%s recieved %s %s message: %s", client, property->device, property->name, message);
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

int myClient(int argc, const char ** argv) {
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
//        indigo_device *protocol_adapter = indigo_xml_client_adapter("indigo_ccd_simulator", "", input[0], output[1]);
//        indigo_attach_device(protocol_adapter);
        indigo_attach_client(&client);
//        indigo_xml_parse(protocol_adapter, &client);
        /* We want to connect to a remote indigo host indigosky.local:7624 */
        indigo_server_entry *server;
        indigo_connect_server("indigosky", "indigosky.local", 7624, &server);
        while (connected == false) {
            indigo_log("waiting for connection to device... ");
            indigo_usleep(ONE_SECOND_DELAY);
        }
        int i;
        for (i=0;i<count;i++) {
            indigo_log("connected is %s...", connected ? "true" : "false");
            indigo_usleep(ONE_SECOND_DELAY);

        }
        while (connected == true) {
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
