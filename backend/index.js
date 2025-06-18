const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

require('dotenv').config();

const Route = require('./Routes/router');  

const app = express();

app.use(cors({
  origin: 'http://localhost:4200', 
  methods: ['GET', 'POST'],
  credentials: true  
}));


app.use(bodyParser.json());
app.use('/api', Route);

const PORT = process.env.PORT;

app.listen(PORT, () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
});
