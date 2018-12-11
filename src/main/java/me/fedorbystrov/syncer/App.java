package me.fedorbystrov.syncer;

import io.javalin.Javalin;

public class App {
  public static void main(String[] args) {
    final var app = Javalin.create().start(7000);
    app.get("/", ctx -> ctx.result("Hello World"));
  }
}
