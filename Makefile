.PHONY : clean pack publish

GMOD_BIN = ~/.steam/steam/steamapps/common/GarrysMod/bin
ADDON_NAME = weaponsets
WORKSHOP_ID = 523399678

clean:
	rm ${ADDON_NAME}.gma

pack:
	${GMOD_BIN}/gmad_linux create -folder . -out ./${ADDON_NAME}.gma

publish: pack
	LD_LIBRARY_PATH=${GMOD_BIN} ${GMOD_BIN}/gmpublish_linux update -id ${WORKSHOP_ID} -addon ${ADDON_NAME}.gma -changes "${changes}"
