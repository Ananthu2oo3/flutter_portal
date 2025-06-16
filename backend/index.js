const express   = require('express');
const cors      = require('cors');
const session   = require('express-session');
const bodyParser = require('body-parser');

require('dotenv').config();

const Route = require('./routes/router');

const app = express();
app.use(cors({
  origin: 'http://localhost:4200',
  methods: ['GET', 'POST'],
  credentials: true
}));

app.use(bodyParser.json());


app.use(session({
  secret: 'your_secret',
  resave: false,
  saveUninitialized: true,
}));


// Routes
app.use('/api', Route);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
