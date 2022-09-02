namespace ExpidusTerminal {
  public class Application : TokyoGtk.Application {
    public Application() {
      Object(application_id: "com.expidus.terminal", flags: GLib.ApplicationFlags.FLAGS_NONE);
    }

    public override void activate() {
      var win = new Window(this);
      this.add_window(win);
      win.show_all();
    }
  }
}

public static int main(string[] args) {
  return new ExpidusTerminal.Application().run(args);
}
