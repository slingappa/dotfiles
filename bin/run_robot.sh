#robot -v OPENBMC_HOST:127.0.0.1 -v SSH_PORT:2222 -v HTTPS_PORT:2443 -v OPENBMC_USERNAME:root -v OPENBMC_PASSWORD:0penBmc \
#	-v IPMI_PORT:2623 -v GUI_IGNORE_SSLERR:True \
#	-v OS_HOST:localhost -v OS_USERNAME:ventana -v OS_PASSWORD:ventana -v OS_SSH_PORT:9991 \
#	-v IMAGE_FILE_PATH:/home/redpanda/git/ventana_openbmc_ws/src/openbmc/build/vttunga/tmp/deploy/images/vttunga/obmc-phosphor-image-vttunga.static.mtd.tar \
#	-v ALTERNATE_IMAGE_FILE_PATH:/home/redpanda/git/ventana_openbmc_ws/src/openbmc/build/vttunga/tmp/deploy/images/vttunga/obmc-phosphor-image-vttunga.static.mtd.tar \
#	-v DEBUG_TARBALL_PATH:/home/redpanda/git/ventana_openbmc_ws/src/openbmc/build/vttunga/tmp/deploy/images/vttunga/obmc-phosphor-debug-tarball-vttunga.tar.xz \
#	-v OVERRIDE_FFDC_ON_TEST_CASE_FAIL:1 -v OS_PWR_SCRIPT:/home/redpanda/git/ventana_openbmc_ws/src/openbmc-test-automation/os_pwr_script.sh redfish/extended/test_fan_operation.robot

 robot -v OPENBMC_HOST:127.0.0.1 -v SSH_PORT:2222 -v HTTPS_PORT:2443 -v OPENBMC_USERNAME:root -v OPENBMC_PASSWORD:0penBmc \
      -v IPMI_PORT:2623 -v GUI_IGNORE_SSLERR:True \
	  -v OS_HOST:localhost -v OS_USERNAME:ventana -v OS_PASSWORD:ventana -v OS_SSH_PORT:9991 \
	  -v IMAGE_FILE_PATH:/usr2/slingapp/scripts/zstage_0.$1.tar.gz \
	-v ALTERNATE_IMAGE_FILE_PATH:/home/redpanda/git/ventana_openbmc_ws/src/openbmc/build/vttunga/tmp/deploy/images/vttunga/obmc-phosphor-image-vttunga.static.mtd.tar \
	-v DEBUG_TARBALL_PATH:/home/redpanda/git/ventana_openbmc_ws/src/openbmc/build/vttunga/tmp/deploy/images/vttunga/obmc-phosphor-debug-tarball-vttunga.tar.xz \
	-v OVERRIDE_FFDC_ON_TEST_CASE_FAIL:1 -v OS_PWR_SCRIPT:/home/redpanda/git/ventana_openbmc_ws/src/openbmc-test-automation/os_pwr_script.sh $1
#	redfish/update_service/test_redfish_bmc_code_update.robot

