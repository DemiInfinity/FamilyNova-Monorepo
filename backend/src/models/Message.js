const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  receiver: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    required: true,
    maxlength: 1000
  },
  messageType: {
    type: String,
    enum: ['text', 'image', 'emoji'],
    default: 'text'
  },
  isModerated: {
    type: Boolean,
    default: false
  },
  moderatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  moderatedAt: Date,
  isRead: {
    type: Boolean,
    default: false
  },
  readAt: Date,
  flagged: {
    type: Boolean,
    default: false
  },
  flaggedReason: String
}, {
  timestamps: true
});

module.exports = mongoose.model('Message', messageSchema);

