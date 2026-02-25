const express = require("express");
const { initDB } = require("./db");
const app = express();
app.use(express.json()); // Add JSON parsing middleware
const PORT = 3000;
initDB().then((db) => {
  app.locals.db = db;
  console.log("Database initialized");
});
app.use((req, res, next) => {
  if (!app.locals.db) {
    return res.status(503).json({ error: "Database not initialized" });
  }
  console.log(`Received ${req.method} request for ${req.url}`);
  next();
});
app.get("/", (req, res) => {
  res.send("Nodemon is watching for changes!");
});
app.use("/patient", require("./patient"));
app.use("/doctor", require("./doctor"));
app.listen(PORT, () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});
