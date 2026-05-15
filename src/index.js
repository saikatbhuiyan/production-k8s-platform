const express = require("express");

const app = express()

const PORT = process.env.PORT || 8080

app.get('/', (req, res) => {
  res.send(`Hello World from K8s! The current time is ${new Date()}`);
})

app.listen(PORT, () => {
  console.log(`App is running on port ${PORT}`)
})

