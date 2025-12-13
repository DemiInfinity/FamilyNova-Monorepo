const mongoose = require('mongoose');

const educationContentSchema = new mongoose.Schema({
  school: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'School',
    required: true
  },
  title: {
    type: String,
    required: true,
    maxlength: 200
  },
  description: {
    type: String,
    maxlength: 1000
  },
  contentType: {
    type: String,
    enum: ['homework', 'lesson', 'quiz', 'resource'],
    required: true
  },
  grade: {
    type: String,
    required: true
  },
  subject: {
    type: String,
    required: true
  },
  dueDate: Date,
  attachments: [{
    name: String,
    url: String,
    type: String
  }],
  assignedTo: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  completedBy: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    completedAt: {
      type: Date,
      default: Date.now
    },
    submission: {
      content: String,
      attachments: [{
        name: String,
        url: String
      }]
    }
  }],
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Indexes for efficient queries
educationContentSchema.index({ school: 1, isActive: 1, createdAt: -1 });
educationContentSchema.index({ assignedTo: 1, isActive: 1, dueDate: 1 });
educationContentSchema.index({ contentType: 1, grade: 1, isActive: 1 });

module.exports = mongoose.model('EducationContent', educationContentSchema);

