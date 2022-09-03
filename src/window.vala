namespace ExpidusTerminal {
  public class Window : TokyoGtk.ApplicationWindow {
    public Vte.Terminal terminal;
    public GLib.Pid shell_pid;

    public Window(Gtk.Application app) {
      Object(application: app);
    }

    construct {
      this.terminal = new Vte.Terminal();
      this.terminal.set_audible_bell(true);
      this.terminal.set_allow_hyperlink(true);
      this.terminal.set_input_enabled(true);
      this.terminal.set_enable_sixel(true);
      this.terminal.set_clear_background(true);
      this.terminal.set_scroll_on_keystroke(true);
      this.terminal.set_scroll_on_output(true);
      this.get_box().pack_end(this.terminal, true, true, 0);

      this.terminal.notify["window-title"].connect(() => {
        this.update_title();
      });

      this.style_manager.hdy.notify["dark"].connect(() => {
        this.update_stylesheet();
      });

      this.style_manager.hdy.notify["high-contrast"].connect(() => {
        this.update_stylesheet();
      });

      this.update_title();
      this.update_stylesheet();

      this.terminal.child_exited.connect(() => {
        this.handle_finish();
      });

      this.terminal.spawn_async(Vte.PtyFlags.DEFAULT, null, { "sh" }, { "TERM=expidus" }, GLib.SpawnFlags.SEARCH_PATH | GLib.SpawnFlags.FILE_AND_ARGV_ZERO, null, -1, null, (term, pid, error) => {
        if (error != null) {
          this.terminal.feed("Failed to spawn shell: %s:%d: %s\r\n".printf(error.domain.to_string(), error.code, error.message).data);
          this.handle_finish();
        }
      });
    }

    private void handle_finish() {
      this.terminal.feed("Process has exited\r\n".data);
      this.terminal.feed("Press any key to exit\r\n".data);

      this.terminal.commit.connect(() => {
        this.application.remove_window(this);
      });
    }

    private void update_stylesheet() {
      Gdk.RGBA palette[16] = {};

      var styling = this.get_style_context();

      styling.lookup_color("window_bg_color", out palette[0]);
      palette[0].alpha = 0.8;

      styling.lookup_color("red_1", out palette[1]);
      styling.lookup_color("green_1", out palette[2]);
      styling.lookup_color("brown_1", out palette[3]);
      styling.lookup_color("blue_5", out palette[4]);
      styling.lookup_color("purple_1", out palette[5]);
      styling.lookup_color("blue_1", out palette[6]);
      styling.lookup_color("light_5", out palette[7]);
      styling.lookup_color("light_3", out palette[8]);
      styling.lookup_color("red_5", out palette[9]);
      styling.lookup_color("green_5", out palette[10]);
      styling.lookup_color("yellow_5", out palette[11]);
      styling.lookup_color("blue_3", out palette[12]);
      styling.lookup_color("purple_3", out palette[13]);
      styling.lookup_color("blue_2", out palette[14]);
      styling.lookup_color("window_fg_color", out palette[15]);

      this.terminal.set_colors(palette[15], palette[0], palette);
    }

    private void update_title() {
      if (this.terminal.window_title != null && this.terminal.window_title.length != 0) {
        this.title = this.terminal.window_title;
      } else {
        this.title = "Terminal";
      }
    }
  }
}
