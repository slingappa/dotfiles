echo Start: $date
#rm -rf ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc2 && mkdir ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc2 && cd  ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc2
#~/git/testscripts/scripts/ventana_setup.sh 0.19.1-rc2 ; cd ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc2/ventana-sw-0.19.1-rc2; ~/git/testscripts/scripts/run_tests.sh smoke
#rm -rf ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc3 && mkdir ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc3 && cd  ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc3
#~/git/testscripts/scripts/ventana_setup.sh 0.19.1-rc3 ; cd ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc3/ventana-sw-0.19.1-rc3; ~/git/testscripts/scripts/run_tests.sh smoe
#cd ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc3/ventana-sw-0.19.1-rc3; ~/git/testscripts/scripts/run_tests.sh smoke
cd ~/git/ventana_openbmc_ws/ts_ws_0.19.1-rc3/ventana-sw-0.19.1-rc3; ~/git/testscripts/scripts/run_tests.sh all

echo Finished: $date
