const express = require("express");
const app = express();
const mysql = require("mysql");
const cors = require("cors");
const os = require('os');

require("dotenv").config();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

const db = mysql.createConnection({
  user: process.env.user,
  host: process.env.host,
  password: process.env.password,
  database: process.env.db,
  ssl: true,
});

app.get('/', (req, res) => {
  const hostname = os.hostname();
  res.send(`Hostname: ${hostname}`);
});

app.get('/ip', (req, res) => {
  const hostname = req.hostname;
  res.send(`Hostname: ${hostname}`);
});


app.post("/users", (req, res) => {
  const { name, father, mother, surname, dob } = req.body;
  db.query(
    "INSERT INTO users (name, father, mother, surname, dob) VALUES (?, ?, ?, ?, ?)",
    [name, father, mother, surname, dob],
    (err, result) => {
      if (err) {
        console.log(err);
      } else {
        res.send("Values Inserted");
      }
    }
  );
});

app.get("/users", (req, res) => {
  db.query("SELECT id, name, father, mother, surname, DATE_FORMAT(dob, '%d/%m/%Y') AS dob FROM users", (err, result) => {
    if (err) {
      console.log(err);
    } else {
      res.send(result);
    }
  });
});

app.get("/users/:id", (req, res) => {
  db.query("SELECT id, name, father, mother, surname, DATE_FORMAT(dob, '%d/%m/%Y') AS dob FROM users WHERE id = $1", [id], (err, result) => {
    if (err) {
      console.log(err);
    } else {
      res.send(result);
    }
  });
});

app.put("/users/:id", (req, res) => {
  const id = parseInt(req.params.id);
  const { name, father, mother, surname, dob } = req.body;

  db.query(
    "UPDATE users SET name = ?, father = ?, mother = ?, surname = ?, dob = ? WHERE id = ?",
    [name, father, mother, surname, dob, id],
    (err, result) => {
      if (err) {
        console.log(err);
        res.status(500).send("Error updating user");
      } else {
        res.send("User updated successfully");
      }
    }
  );
});

app.delete("/users/:id", (req, res) => {
  const id = req.params.id;
  db.query("DELETE FROM users WHERE id = ?", id, (err, result) => {
    if (err) {
      console.log(err);
    } else {
      res.send(result);
    }
  });
});

app.listen(80, function () {
  console.log('Example app listening on port 80.');
});