using Gtk;

[CCode (cname = "rust_part", cheader_filename = "langs/chain.h")]
extern double rust_part (int op, double a, double b);
[CCode (cname = "go_part", cheader_filename = "langs/chain.h")]
extern double go_part (int op, double a, double b);
[CCode (cname = "zig_part", cheader_filename = "langs/chain.h")]
extern double zig_part (int op, double a, double b);
[CCode (cname = "d_part", cheader_filename = "langs/chain.h")]
extern double d_part (int op, double a, double b);
[CCode (cname = "nim_part", cheader_filename = "langs/chain.h")]
extern double nim_part (int op, double a, double b);
[CCode (cname = "cpp_part", cheader_filename = "langs/chain.h")]
extern double cpp_part (int op, double a, double b);
[CCode (cname = "ada_part", cheader_filename = "langs/chain.h")]
extern double ada_part (int op, double a, double b);

[CCode (cname = "FcConfigAppFontAddFile", cheader_filename = "fontconfig/fontconfig.h")]
extern bool fc_config_app_font_add_file (void* config, string file);

[CCode (cname = "FcConfigGetCurrent", cheader_filename = "fontconfig/fontconfig.h")]
extern void* fc_config_get_current ();

[CCode (cname = "g_resources_lookup_data", cheader_filename = "gio/gio.h")]
extern void* g_resources_lookup_data (string path, int flags, void* error = null);

[CCode (cname = "g_bytes_get_data", cheader_filename = "glib.h")]
extern unowned uint8* g_bytes_get_data (void* bytes, out size_t size);

[CCode (cname = "g_bytes_unref", cheader_filename = "glib.h")]
extern void g_bytes_unref (void* bytes);

[CCode (cname = "close", cheader_filename = "unistd.h")]
extern int close_fd (int fd);


errordomain CalcError {
    SYNTAX,
    DIV_ZERO
}

// recursive-descent evaluator: + - * / ( ) and unary minus.
private class Parser : Object {
    private string s;
    private int pos = 0;

    public Parser(string src) {
        this.s = src;
    }

    private double chain(char op, double a, double b) throws CalcError {
        int operation = op == '+' ? 0 : op == '-' ? 1 : op == '*' ? 2 : 3;
        double pieces = 8.0;
        double left = a / pieces;
        double right = (op == '+' || op == '-') ? b / pieces : b;
        double[] results = {
            rust_part(operation, left, right),
            go_part(operation, left, right),
            zig_part(operation, left, right),
            d_part(operation, left, right),
            nim_part(operation, left, right),
            cpp_part(operation, left, right),
            ada_part(operation, left, right)
        };
        string script = Path.build_filename(Environment.get_current_dir(), "langs", "part.lua");
        string output;
        int status;
        string[] command = {"lua", script, "aggregate", "%c".printf(op),
                            "%.17g".printf(left), "%.17g".printf(right)};
        string[] args = new string[command.length + results.length];
        for (int i = 0; i < command.length; i++) args[i] = command[i];
        for (int i = 0; i < results.length; i++) args[command.length + i] = "%.17g".printf(results[i]);
        try {
            Process.spawn_sync(null, args,
                null, SpawnFlags.SEARCH_PATH, null,
                out output, null, out status);
        } catch (SpawnError e) {
            throw new CalcError.SYNTAX("Lua chain unavailable: %s".printf(e.message));
        }
        if (status != 0)
            throw new CalcError.SYNTAX("Lua chain failed");
        return double.parse(output.strip());
    }

    private void skip() {
        while (pos < s.length && s[pos] == ' ')
            pos++;
    }

    private char peek() {
        skip();
        return pos < s.length ? s[pos] : '\0';
    }

    public double parse() throws CalcError {
        double v = expr();
        if (peek() != '\0')
            throw new CalcError.SYNTAX("unexpected '%c'".printf(s[pos]));
        return v;
    }

    private double expr() throws CalcError {
        double v = term();
        for (;;) {
            char c = peek();
            if (c == '+') {
                pos++;
                v = chain('+', v, term());
            } else if (c == '-') {
                pos++;
                v = chain('-', v, term());
            } else {
                return v;
            }
        }
    }

    private double term() throws CalcError {
        double v = factor();
        for (;;) {
            char c = peek();
            if (c == '*') {
                pos++;
                v = chain('*', v, factor());
            } else if (c == '/') {
                pos++;
                double d = factor();
                if (d == 0)
                    throw new CalcError.DIV_ZERO("division by zero");
                v = chain('/', v, d);
            } else {
                return v;
            }
        }
    }

    private double factor() throws CalcError {
        char c = peek();
        if (c == '+') {
            pos++;
            return factor();
        }
        if (c == '-') {
            pos++;
            return -factor();
        }
        if (c == '(') {
            pos++;
            double v = expr();
            if (peek() != ')')
                throw new CalcError.SYNTAX("missing ')'");
            pos++;
            return v;
        }
        return number();
    }

    private double number() throws CalcError {
        skip();
        int start = pos;
        while (pos < s.length && (s[pos].isdigit() || s[pos] == '.'))
            pos++;
        if (pos == start)
            throw new CalcError.SYNTAX("expected a number");
        return double.parse(s.substring(start, pos - start));
    }
}

public class WeirdCalculator : Window {
    private Entry entry;
    private Label footer;
    private string? font_tmp_path = null;

    public WeirdCalculator() {
        title = "vavilon calculator";
        window_position = WindowPosition.CENTER;
        set_default_size(400, 620);
        set_size_request(400, 620);
        border_width = 18;
        resizable = false;
	void* gbytes_font = g_resources_lookup_data("/space/brightcat/vavilon/ZXX-Sans.otf", 0, null);

	if (gbytes_font != null) {
    		size_t font_size = 0;
   	 	uint8* font_data = g_bytes_get_data(gbytes_font, out font_size);

    		if (font_data != null && font_size > 0) {
        		try {
            			string tmp_path;
            			int fd = GLib.FileUtils.open_tmp("zxx-sans-XXXXXX", out tmp_path);
            			close_fd(fd);
            			uint8[] font_bytes = new uint8[font_size];
            			for (size_t i = 0; i < font_size; i++)
                			font_bytes[i] = font_data[i];
            			GLib.FileUtils.set_data(tmp_path, font_bytes);
            			font_tmp_path = tmp_path;
            			void* current_config = fc_config_get_current();
            			bool success = fc_config_app_font_add_file(current_config, tmp_path);
            			if (!success) {
                			warning("Fontconfig failed to accept ZXX font");
            			}
        		} catch (GLib.FileError e) {
            			warning("font: %s", e.message);
        		}
    		}
    		g_bytes_unref(gbytes_font);
	} else {
    		warning("Could not find ZXX font inside resources!");
	}

	destroy.connect(() => {
    		if (font_tmp_path != null)
        		GLib.FileUtils.unlink(font_tmp_path);
	});

	var box = new Box(Orientation.VERTICAL, 14);
        add(box);

        var banner = new Label("·´¯`·.  vavilon calculator  .·´¯`·");
        banner.get_style_context().add_class("banner");
        banner.set_angle(-5.0);
        box.pack_start(banner, false, false, 0);

        entry = new Entry();
        entry.xalign = 1.0f;
        entry.get_style_context().add_class("screen");
        entry.set_placeholder_text("type...");
        box.pack_start(entry, false, false, 0);
        entry.activate.connect(() => on_key("="));

         var grid = new Grid();
         grid.column_homogeneous = false;
         grid.row_homogeneous = false;
         grid.halign = Align.CENTER;
         grid.valign = Align.CENTER;
         grid.row_spacing = 6;
        grid.column_spacing = 6;
        box.pack_start(grid, true, true, 0);

        // "=" now lives top-left, "C" now squats in the bottom-right corner.
        string[,] keys = {
            { "=",   "(",  ")",  "/" },
            { "7",   "8",  "9",  "*" },
            { "4",   "5",  "6",  "-" },
            { "1",   "2",  "3",  "+" },
            { "⌫",   "0",  ".",  "C" }
        };

         for (int r = 0; r < 5; r++) {
            for (int c = 0; c < 4; c++) {
                string k = keys[r, c];
                var btn = make_button(k, r, c);
                btn.clicked.connect(() => on_key(k));
                grid.attach(btn, c, r, 1, 1);
             }
         }

         footer = new Label("chain: Vala -> split(8) -> Rust -> Go -> Zig -> D -> Nim -> C++ -> Ada -> Lua(sum)");
         footer.get_style_context().add_class("footer");
         footer.set_size_request(360, 34);
         footer.set_line_wrap(true);
         footer.set_max_width_chars(48);
         footer.set_justify(Justification.CENTER);
         box.pack_start(footer, false, false, 0);

         string css = """
            window { background: #3d382c; }
            .banner {
                color: #e7d7a4;
                font-family: "Comic Sans MS", "Purisa", cursive, serif;
                font-weight: bold;
                font-size: 21px;
                letter-spacing: 2px;
                text-shadow: 2px 2px 0 #191712;
            }
            .screen {
                background: #ece0c2;
                color: #201d16;
                font-family: monospace;
                font-weight: bold;
                font-size: 30px;
                border: 3px dashed #6d5c3d;
                border-radius: 20px 5px 24px 7px;
                padding: 10px 14px;
                box-shadow: inset 4px 4px 9px #b6a679, inset -3px -3px 7px #fffbe9;
                caret-color: #6d5c3d;
            }
            .footer {
                color: #8f8463;
                font-family: "Comic Sans MS", cursive, serif;
                font-size: 11px;
                letter-spacing: 3px;
                margin-top: 4px;
            }
            button {
                font-family: "ZXX", "ZXX Sans", cursive, serif;
                font-weight: bold;
                font-size: 24px;
                color: #1c1912;
                padding: 6px;
                border-width: 2px;
                border-color: #1c1912;
                box-shadow: 3px 3px 0 #1c1912;
                min-width: 0;
                min-height: 0;
            }
            /* mossy number blobs */
            button.num0 { background: #9aa86a; }
            button.num1 { background: #b4be86; }
            button.num2 { background: #83915a; }
            button.num0:hover { background: #adba7d; }
            button.num1:hover { background: #c6cf9e; }
            button.num2:hover { background: #97a56c; }
            /* rusty operator blobs */
            button.op { color: #fff4de; border-color: #3a1f10; box-shadow: 3px 3px 0 #3a1f10; }
            button.op0 { background: #b5651d; }
            button.op1 { background: #c97b3a; }
            button.op2 { background: #8f4f16; }
            button.op0:hover { background: #cc7a2c; }
            button.op1:hover { background: #d98f51; }
            button.op2:hover { background: #a55f21; }
            /* C, the grey wallflower */
            button.clr {
                background: #6f6a58;
                color: #f3ead2;
                border-color: #26231c;
                box-shadow: 3px 3px 0 #26231c;
            }
            button.clr:hover { background: #827c68; }
            /* =, the plum bully */
            button.eq {
                background: #4b3b6b;
                color: #f0e6ff;
                font-size: 26px;
                border-color: #221936;
                box-shadow: 4px 4px 0 #221936;
            }
            button.eq:hover { background: #5c4885; }
            /* uneven organic silhouettes */
            button.blob0 { border-radius: 26px 8px 26px 8px; }
            button.blob1 { border-radius: 8px 26px 8px 26px; }
            button.blob2 { border-radius: 30px 30px 6px 6px; }
            button.blob3 { border-radius: 6px 6px 30px 30px; }
            button.blob4 { border-radius: 24px 10px 10px 24px; }
            button.blob5 { border-radius: 10px 24px 24px 10px; }
        """;

        var provider = new CssProvider();
        try {
            provider.load_from_data(css);
        } catch (Error e) {
            warning("css: %s", e.message);
        }
        StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider,
            STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    private Button make_button(string k, int r, int c) {
        int h = r * 31 + c * 17 + r * c * 7;

        var label = new Label(null);
        label.set_markup("<b>%s</b>".printf(k));
        label.set_angle(((h * 7) % 41) - 20.0); // every key leans its own way

        var btn = new Button();
        btn.add(label);
        btn.set_size_request(50 + (h % 3) * 12, 50 + ((h / 2) % 3) * 12);
        btn.margin_start = h % 5;
        btn.margin_end = (h / 3) % 5;
        btn.margin_top = (h / 5) % 5;
        btn.margin_bottom = (h / 7) % 5;

        var ctx = btn.get_style_context();
        ctx.add_class("blob%d".printf(h % 6));
        if (k == "=") {
            ctx.add_class("eq");
        } else if (is_clr(k)) {
            ctx.add_class("clr");
        } else if (is_op(k)) {
            ctx.add_class("op");
            ctx.add_class("op%d".printf(h % 3));
        } else {
            ctx.add_class("num%d".printf(h % 3));
        }
        return btn;
    }

    private bool is_op(string k) {
        return k == "+" || k == "-" || k == "*" || k == "/" ||
               k == "(" || k == ")" || k == ".";
    }

    private bool is_clr(string k) {
        return k == "C" || k == "⌫";
    }

    private void on_key(string k) {
        string t = entry.text;
        switch (k) {
            case "C":
                entry.text = "";
                break;
            case "⌫":
                if (t.length > 0)
                    entry.text = t.substring(0, t.length - 1);
                break;
            case "=":
                if (t.strip() == "")
                    break;
                try {
                    double r = new Parser(t).parse();
                    entry.text = "%.10g".printf(r).replace(",", ".");
                    footer.set_text("chain: %s -> split(8) -> Rust -> Go -> Zig -> D -> Nim -> C++ -> Ada -> Lua(sum) = %s".printf(t, entry.text));
                } catch (CalcError e) {
                    entry.text = "ERR: %s".printf(e.message);
                    footer.set_text("chain stopped: %s".printf(e.message));
                }
                break;
            default:
                entry.text = t + k;
                break;
        }
        entry.set_position(-1);
    }
}

int main(string[] args) {
    Gtk.init(ref args);
    var win = new WeirdCalculator();
    win.destroy.connect(() => Gtk.main_quit());
    win.show_all();
    Gtk.main();
    return 0;
}
