namespace ExpidusTerminal {
  public class Window : TokyoGtk.ApplicationWindow {
    public Vte.Terminal terminal;
    private TokyoGtk.StyleManager style_manager;

    public Window(Gtk.Application app) {
      Object(application: app);
    }

    construct {
      this.style_manager = TokyoGtk.StyleManager.get_for_display(this.get_display());

      this.terminal = new Vte.Terminal();
      this.terminal.set_audible_bell(true);
      this.terminal.set_allow_hyperlink(true);
      this.terminal.set_input_enabled(true);
      this.terminal.set_enable_sixel(true);
      this.terminal.set_clear_background(true);
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

      this.terminal.spawn_async(Vte.PtyFlags.DEFAULT, null, { "/bin/sh" }, GLib.Environ.@get(), GLib.SpawnFlags.SEARCH_PATH_FROM_ENVP, null, 0, null, (term, pid, error) => {
        if (error != null) this.terminal.feed("Failed to spawn shell: %s:%d: %s\r\n".printf(error.domain.to_string(), error.code, error.message).data);

        this.terminal.feed("Process %d has exited, press any key to exit".printf(pid).data);

        this.terminal.commit.connect(() => {
          this.application.remove_window(this);
        });
      });
    }

    private void update_stylesheet() {
      Gdk.RGBA background_color = { 0.0, 0.0, 0.0, 1.0 };
      Gdk.RGBA foreground_color = { 1.0, 1.0, 1.0, 1.0 }; 
      
      switch (this.style_manager.color_scheme) {
        case TokyoGtk.ColorScheme.NIGHT:
          background_color.parse("#1a1b26");
          foreground_color.parse("#a9b1d6");
          break;
        case TokyoGtk.ColorScheme.LIGHT:
          break;
        case TokyoGtk.ColorScheme.STORM:
          background_color.parse("#24283b");
          foreground_color.parse("#a9b1d6");
          break;
      }

      background_color.alpha = 0.8;

      this.terminal.set_color_background(background_color);
      this.terminal.set_color_foreground(foreground_color);
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
