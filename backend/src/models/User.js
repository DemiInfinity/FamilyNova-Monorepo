const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  userType: {
    type: String,
    enum: ['kid', 'parent'],
    required: true
  },
  profile: {
    firstName: String,
    lastName: String,
    displayName: String,
    avatar: String,
    dateOfBirth: Date,
    school: String,
    grade: String
  },
  verification: {
    parentVerified: {
      type: Boolean,
      default: false
    },
    schoolVerified: {
      type: Boolean,
      default: false
    },
    verifiedAt: Date
  },
  parentAccount: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  children: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  friends: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  parentConnections: [{
    parent: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    connectedAt: {
      type: Date,
      default: Date.now
    }
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  lastLogin: Date
}, {
  timestamps: true
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Check if user is fully verified (two-tick system)
userSchema.methods.isFullyVerified = function() {
  if (this.userType === 'kid') {
    return this.verification.parentVerified && this.verification.schoolVerified;
  }
  return true; // Parents don't need school verification
};

module.exports = mongoose.model('User', userSchema);

