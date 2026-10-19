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
[CCode (cname = "nab_part", cheader_filename = "langs/chain.h")]
extern double nab_part (int op, double a, double b);

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

    private double run_script(string[] args, string language) throws CalcError {
        string output;
        int status;
        try {
            Process.spawn_sync(null, args,
                null, SpawnFlags.SEARCH_PATH, null,
                out output, null, out status);
        } catch (SpawnError e) {
            throw new CalcError.SYNTAX("%s chain unavailable: %s".printf(language, e.message));
        }
        if (status != 0)
            throw new CalcError.SYNTAX("%s chain failed".printf(language));
        string text = output.strip();
        if (text == "")
            throw new CalcError.SYNTAX("%s chain returned no output".printf(language));
        double value;
        if (!double.try_parse(text, out value))
            throw new CalcError.SYNTAX("%s chain returned invalid output".printf(language));
        return value;
    }

    private double perl_piece(int op, double a, double b) throws CalcError {
        string script = Path.build_filename(Environment.get_current_dir(), "langs", "part.pl");
        string[] args = {"perl", script, "eval", "%d".printf(op),
                         "%.17g".printf(a), "%.17g".printf(b)};
        return run_script(args, "Perl");
    }

    public double chain(int op, double a, double b) throws CalcError {
        double left, right;
        if (op <= 3) {
            left = a / 10.0;
            right = (op == 0 || op == 1) ? b / 10.0 : b;
        } else {
            left = a;
            right = b;
        }
        double[] results = {
            rust_part(op, left, right),
            go_part(op, left, right),
            zig_part(op, left, right),
            d_part(op, left, right),
            nim_part(op, left, right),
            cpp_part(op, left, right),
            ada_part(op, left, right),
            perl_piece(op, left, right),
            nab_part(op, left, right),
        };
        string script = Path.build_filename(Environment.get_current_dir(), "langs", "part.lua");
        string[] command = {"lua", script, "aggregate", "%d".printf(op),
                            "%.17g".printf(left), "%.17g".printf(right)};
        string[] args = new string[command.length + results.length];
        for (int i = 0; i < command.length; i++) args[i] = command[i];
        for (int i = 0; i < results.length; i++) args[command.length + i] = "%.17g".printf(results[i]);
        return run_script(args, "Lua");
    }

    private void skip() {
        while (pos < s.length && s[pos] == ' ')
            pos++;
    }

    private char peek() {
        skip();
        return pos < s.length ? s[pos] : '\0';
    }

    private bool is_alpha (char c) {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
    }

    private string read_ident() {
        skip();
        int start = pos;
        while (pos < s.length && (is_alpha(s[pos]) || s[pos].isdigit() || s[pos] == '_'))
            pos++;
        return s.substring(start, pos - start);
    }

    private void expect(char c) throws CalcError {
        if (peek() != c)
            throw new CalcError.SYNTAX("expected '%c'".printf(c));
        pos++;
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
                v = chain(0, v, term());
            } else if (c == '-') {
                pos++;
                v = chain(1, v, term());
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
                v = chain(2, v, factor());
            } else if (c == '/') {
                pos++;
                double d = factor();
                if (d == 0)
                    throw new CalcError.DIV_ZERO("division by zero");
                v = chain(3, v, d);
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
            expect(')');
            return v;
        }
        if (is_alpha(c)) {
            string name = read_ident();
            skip();
            expect('(');
            double a = expr();
            double b = 0;
            bool has_b = false;
            if (peek() == ',') {
                pos++;
                b = expr();
                has_b = true;
            }
            expect(')');
            return call_named(name, a, b, has_b);
        }
        return number();
    }

    private double call_named(string name, double a, double b, bool has_b) throws CalcError {
        if (name == "sqrt")   return chain(4, a, 0);
        if (name == "sq")     return chain(5, a, 0);
        if (name == "abs")    return chain(6, a, 0);
        if (name == "fact")   return chain(7, a, 0);
        if (name == "isprime")return chain(8, a, 0);
        if (name == "gcd")    return chain(9, a, b);
        if (name == "lcm")    return chain(10, a, b);
        if (name == "bin")    return chain(11, a, 0);
        if (name == "dec")    return chain(12, a, 0);
        if (name == "area_rect")   return chain(13, a, b);
        if (name == "area_circle") return chain(14, a, 0);
        if (name == "hypot")  return chain(15, a, b);
        if (name == "avg")    return chain(16, a, b);
        throw new CalcError.SYNTAX("unknown function '%s'".printf(name));
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
        set_default_size(420, 760);
        set_size_request(420, 760);
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

        var box = new Box(Orientation.VERTICAL, 10);
        add(box);

        var banner = new Label("·´¯`·.  vavilon calculator  .·´¯`·");
        banner.get_style_context().add_class("banner");
        banner.set_angle(-5.0);
        box.pack_start(banner, false, false, 0);

        entry = new Entry();
        entry.xalign = 1.0f;
        entry.get_style_context().add_class("screen");
        entry.set_placeholder_text("type... or tap a function");
        box.pack_start(entry, false, false, 0);
        entry.activate.connect(() => on_key("="));

        // function rows
        var fgrid = new Grid();
        fgrid.row_homogeneous = true;
        fgrid.column_homogeneous = true;
        fgrid.row_spacing = 4;
        fgrid.column_spacing = 4;
        box.pack_start(fgrid, false, false, 0);

        string[,] fkeys = {
            { "√", "x²", "|x|", "!", "p?", "C" },
            { "gcd", "lcm", "bin", "dec", "avg", "⌫" },
            { "□", "○", "h", "=", "", "" }
        };

        for (int r = 0; r < 3; r++) {
            for (int c = 0; c < 6; c++) {
                string fk = fkeys[r, c];
                if (fk == "") continue;
                var fb = new Button.with_label(fk);
                fb.get_style_context().add_class("fnbtn");
                if (fk == "=") fb.get_style_context().add_class("eq");
                if (fk == "C" || fk == "⌫") fb.get_style_context().add_class("clr");
                fb.clicked.connect(() => on_key(fk));
                fgrid.attach(fb, c, r, 1, 1);
            }
        }

        // main numpad
        var grid = new Grid();
        grid.column_homogeneous = false;
        grid.row_homogeneous = false;
        grid.halign = Align.CENTER;
        grid.valign = Align.CENTER;
        grid.row_spacing = 6;
        grid.column_spacing = 6;
        box.pack_start(grid, true, true, 0);

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

        footer = new Label("chain: Vala -> split(10) -> Rust -> Go -> Zig -> D -> Nim -> C++ -> Ada -> Perl -> NAB -> Lua(sum)");
        footer.get_style_context().add_class("footer");
        footer.set_size_request(380, 44);
        footer.set_line_wrap(true);
        footer.set_max_width_chars(56);
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
                letter-spacing: 2px;
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
            .fnbtn {
                font-size: 16px;
                background: #5b6d8c;
                color: #f2f6ff;
                border-color: #1a2438;
                box-shadow: 2px 2px 0 #1a2438;
                padding: 4px;
            }
            .fnbtn:hover { background: #6c80a3; }
            button.num0 { background: #9aa86a; }
            button.num1 { background: #b4be86; }
            button.num2 { background: #83915a; }
            button.num0:hover { background: #adba7d; }
            button.num1:hover { background: #c6cf9e; }
            button.num2:hover { background: #97a56c; }
            button.op { color: #fff4de; border-color: #3a1f10; box-shadow: 3px 3px 0 #3a1f10; }
            button.op0 { background: #b5651d; }
            button.op1 { background: #c97b3a; }
            button.op2 { background: #8f4f16; }
            button.op0:hover { background: #cc7a2c; }
            button.op1:hover { background: #d98f51; }
            button.op2:hover { background: #a55f21; }
            button.clr {
                background: #6f6a58;
                color: #f3ead2;
                border-color: #26231c;
                box-shadow: 3px 3px 0 #26231c;
            }
            button.clr:hover { background: #827c68; }
            button.eq {
                background: #4b3b6b;
                color: #f0e6ff;
                font-size: 26px;
                border-color: #221936;
                box-shadow: 4px 4px 0 #221936;
            }
            button.eq:hover { background: #5c4885; }
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
        label.set_angle(((h * 7) % 41) - 20.0);

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

    private string insert_for(string k) {
        if (k == "√") return "sqrt(";
        if (k == "x²") return "sq(";
        if (k == "|x|") return "abs(";
        if (k == "!") return "fact(";
        if (k == "p?") return "isprime(";
        if (k == "gcd") return "gcd(";
        if (k == "lcm") return "lcm(";
        if (k == "bin") return "bin(";
        if (k == "dec") return "dec(";
        if (k == "avg") return "avg(";
        if (k == "□") return "area_rect(";
        if (k == "○") return "area_circle(";
        if (k == "h") return "hypot(";
        return k;
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
                    footer.set_text("chain: split(10) -> Rust -> Go -> Zig -> D -> Nim -> C++ -> Ada -> Perl -> NAB -> Lua = %s".printf(entry.text));
                } catch (CalcError e) {
                    entry.text = "ERR: %s".printf(e.message);
                    footer.set_text("chain stopped: %s".printf(e.message));
                }
                break;
            default:
                entry.text = t + insert_for(k);
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
