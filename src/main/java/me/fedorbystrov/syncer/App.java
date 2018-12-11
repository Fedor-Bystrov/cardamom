package me.fedorbystrov.syncer;

import io.javalin.Javalin;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {
  private static final Logger LOGGER = LoggerFactory.getLogger(App.class);

  public static void main(String[] args) {
    final var app = Javalin.create().start(7000);
    app.get("/webhooks/wunderlist", ctx -> LOGGER.info(
        "Callback from wunderlist! body: ",
        ctx, ctx.req, ctx.body()));
  }
}
