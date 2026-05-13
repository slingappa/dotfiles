set -x
rm -f *.bin
#./frugen --board-mfg Ventana Microsystems --board-pname Ventana BMC --board-pn BRD-PN-123 --board-date \'30/04/2025 00:00:00\' --board-serial 01171234 --board-file Command Line --binary --board-custom 01020304FEAD1E fru.bin
#./frugen --board-mfg "Ventana Microsystems" \
#	--board-pname "Ventana BMC PS0 I2C2@50" \
#	--board-pn "PS-BRD-PN-123" \
#	--board-date "01/01/2025 12:58:00" \
#	--board-serial "01171234" \
#	--board-file "Command Line" \
#	--prod-atag "VentanaAST2600SynthV2" \
#	--binary --board-custom "01020304FEAD1E" \
#	fru.bin
#hexdump -C ./fru.bin
#hexdump -e  '8/1 "0x%02x, " "\n"' ./fru.bin

rm ./test.bin; ./frugen -I --prod-name "Ventana BMC PS0 Board" --prod-mfg "Ventana Microsystems" --prod-modelpn "Ventana AST2600"  --prod-version "11112222" --prod-serial "33334444" --prod-atag "VentanaAST2600PS0" test.bin
hexdump -C test.bin
 hexdump -e  '8/1 "0x%02x, " "\n"' ./test.bin
 read

rm ./test.bin; ./frugen -I --prod-name "Ventana BMC Board" --prod-mfg "Ventana Microsystems" --prod-modelpn "Ventana AST2600"  --prod-version "11112222" --prod-serial "33334444" --prod-atag "VentanaAST2600BMC" test.bin
hexdump -C test.bin
 hexdump -e  '8/1 "0x%02x, " "\n"' ./test.bin
 read

rm ./test.bin; ./frugen -I --prod-name "Ventana BMC Motherboard" --prod-mfg "Ventana Microsystems" --prod-modelpn "Ventana Synthetic Board AST2600"  --prod-version "11112222" --prod-serial "33334444" --prod-atag "VentanaAST2600Mb" test.bin
hexdump -C test.bin
 hexdump -e  '8/1 "0x%02x, " "\n"' ./test.bin
 read

rm ./test.bin;   ./frugen -I --prod-name "Ventana BMC Storage" --prod-mfg "Ventana Microsystems" --prod-modelpn "Ventana AST2600"  --prod-version "11112222" --prod-serial "33334444" --prod-atag "VentanaAST2600Storage" test.bin
hexdump -C test.bin
   hexdump -e  '8/1 "0x%02x, " "\n"' ./test.bin
 read

rm ./test.bin;   ./frugen -I --prod-name "Ventana BMC Riser" --prod-mfg "Ventana Microsystems" --prod-modelpn "Ventana AST2600"  --prod-version "11112222" --prod-serial "33334444" --prod-atag "VentanaAST2600Riser" test.bin
hexdump -C test.bin
hexdump -e  '8/1 "0x%02x, " "\n"' ./test.bin
 read

