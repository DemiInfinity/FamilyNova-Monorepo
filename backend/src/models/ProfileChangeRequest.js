const mongoose = require('mongoose');

const profileChangeRequestSchema = new mongoose.Schema({
  child: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  parent: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  changes: {
    displayName: String,
    avatar: String,
    school: String,
    grade: String,
    // Store the old values for comparison
    oldDisplayName: String,
    oldAvatar: String,
    oldSchool: String,
    oldGrade: String
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending'
  },
  reviewedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  reviewedAt: Date,
  rejectionReason: String
}, {
  timestamps: true
});

// Index for efficient queries
profileChangeRequestSchema.index({ child: 1, status: 1, createdAt: -1 });
profileChangeRequestSchema.index({ parent: 1, status: 1, createdAt: -1 });

module.exports = mongoose.model('ProfileChangeRequest', profileChangeRequestSchema);

