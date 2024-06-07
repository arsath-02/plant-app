const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const cors = require('cors'); // Import cors

dotenv.config();

const app = express();

app.use(bodyParser.json());
app.use(cors()); // Enable CORS

// Enhanced logging for debugging connection issues
mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.error('Could not connect to MongoDB:', err);
    console.error('Connection error details:', err.reason);
  });

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  password: { type: String, required: true },
});

const User = mongoose.model('User', userSchema);

app.post('/api/register', async (req, res, next) => {
  try {
    const { name, email, phoneNumber, password } = req.body;

    console.log(req.body); // Log the incoming request body

    if (!name || !email || !phoneNumber || !password) {
      return res.status(400).send({ message: 'All fields are required' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).send({ message: 'Email already in use' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      name,
      email,
      phoneNumber,
      password: hashedPassword,
    });

    await user.save(); // Save the user to the database
    res.send({ message: 'User registration successful' });
  } catch (error) {
    console.error('Error processing registration:', error);
    next(error);
  }
});

// Global error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send({ message: 'Something went wrong!' });
});

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));

// Ensure your .env file contains the correct MongoDB URI
// MONGODB_URI=mongodb+srv://username:password@registerpage.7c32noh.mongodb.net/mydatabase?retryWrites=true&w=majority&appName=registerpage
