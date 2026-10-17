all:
	glib-compile-resources resources.gresource.xml --target=resources.c --generate-source
	valac -C calculator.vala --pkg gtk+-3.0 --pkg gio-2.0
	gcc calculator.c resources.c `pkg-config --cflags --libs gtk+-3.0 gio-2.0` -lfontconfig -o calculator

clean:
	rm -f calculator calculator.c resources.c

