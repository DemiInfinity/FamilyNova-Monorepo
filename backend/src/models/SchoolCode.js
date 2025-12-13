const mongoose = require('mongoose');

const schoolCodeSchema = new mongoose.Schema({
  code: {
    type: String,
    required: true,
    unique: true,
    uppercase: true
  },
  school: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'School',
    required: true
  },
  generatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'School',
    required: true
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  grade: {
    type: String,
    required: true
  },
  expiresAt: {
    type: Date,
    default: function() {
      // Codes expire after 30 days
      const date = new Date();
      date.setDate(date.getDate() + 30);
      return date;
    }
  },
  usedAt: Date,
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Generate unique code before saving
schoolCodeSchema.pre('save', async function(next) {
  if (!this.code) {
    // Generate a 6-character alphanumeric code
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Exclude confusing chars
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    
    // Ensure uniqueness
    let isUnique = false;
    while (!isUnique) {
      const existing = await mongoose.model('SchoolCode').findOne({ code });
      if (!existing) {
        isUnique = true;
      } else {
        code = '';
        for (let i = 0; i < 6; i++) {
          code += chars.charAt(Math.floor(Math.random() * chars.length));
        }
      }
    }
    
    this.code = code;
  }
  next();
});

// Indexes
schoolCodeSchema.index({ code: 1 });
schoolCodeSchema.index({ school: 1, isActive: 1 });
schoolCodeSchema.index({ assignedTo: 1 });

module.exports = mongoose.model('SchoolCode', schoolCodeSchema);

