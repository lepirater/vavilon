all:
	cd langs && bash build.sh
	glib-compile-resources resources.gresource.xml --target=resources.c --generate-source
	valac -C calculator.vala --pkg gtk+-3.0 --pkg gio-2.0
	gcc -no-pie calculator.c resources.c `pkg-config --cflags --libs gtk+-3.0 gio-2.0` -lfontconfig \
		-I. -Llangs -Wl,-rpath,'$$ORIGIN/langs' -lgopart -lnimpart \
		langs/librustpart.a langs/libzigpart.a langs/dpart.o -lm -o calculator

clean:
	rm -f calculator calculator.c resources.c
