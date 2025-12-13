const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const Message = require('../models/Message');
const User = require('../models/User');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   POST /api/messages
// @desc    Send a message (kids only)
// @access  Private (Kid only)
router.post('/', requireUserType('kid'), [
  body('receiverId').notEmpty(),
  body('content').trim().isLength({ min: 1, max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { receiverId, content, messageType } = req.body;
    
    // Verify receiver is a friend
    const receiver = await User.findById(receiverId);
    if (!receiver || receiver.userType !== 'kid') {
      return res.status(404).json({ error: 'Receiver not found' });
    }
    
    if (!req.user.friends.includes(receiverId)) {
      return res.status(403).json({ error: 'Can only message friends' });
    }
    
    const message = new Message({
      sender: req.user._id,
      receiver: receiverId,
      content,
      messageType: messageType || 'text'
    });
    
    await message.save();
    
    res.status(201).json({
      message: {
        id: message._id,
        content: message.content,
        sender: {
          id: req.user._id,
          displayName: req.user.profile.displayName
        },
        receiver: {
          id: receiver._id,
          displayName: receiver.profile.displayName
        },
        createdAt: message.createdAt
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/messages
// @desc    Get messages for current user
// @access  Private
router.get('/', async (req, res) => {
  try {
    const { conversationWith } = req.query;
    
    let query = {
      $or: [
        { sender: req.user._id },
        { receiver: req.user._id }
      ]
    };
    
    if (conversationWith) {
      query = {
        $or: [
          { sender: req.user._id, receiver: conversationWith },
          { sender: conversationWith, receiver: req.user._id }
        ]
      };
    }
    
    const messages = await Message.find(query)
      .sort({ createdAt: -1 })
      .limit(50)
      .populate('sender receiver', 'profile displayName avatar')
      .lean();
    
    // Mark messages as read if user is receiver
    await Message.updateMany(
      { receiver: req.user._id, isRead: false },
      { isRead: true, readAt: new Date() }
    );
    
    res.json({ messages: messages.reverse() });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   PUT /api/messages/:messageId/moderate
// @desc    Moderate a message (parents only)
// @access  Private (Parent only)
router.put('/:messageId/moderate', requireUserType('parent'), async (req, res) => {
  try {
    const { messageId } = req.params;
    const { action } = req.body; // 'approve', 'flag', 'delete'
    
    const message = await Message.findById(messageId)
      .populate('sender receiver');
    
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }
    
    // Verify parent has access to this message (child is sender or receiver)
    const parent = await User.findById(req.user._id);
    const hasAccess = parent.children.some(
      childId => childId.toString() === message.sender._id.toString() || 
                 childId.toString() === message.receiver._id.toString()
    );
    
    if (!hasAccess) {
      return res.status(403).json({ error: 'No access to this message' });
    }
    
    if (action === 'approve') {
      message.isModerated = true;
      message.moderatedBy = req.user._id;
      message.moderatedAt = new Date();
    } else if (action === 'flag') {
      message.flagged = true;
      message.flaggedReason = req.body.reason || 'Flagged by parent';
    } else if (action === 'delete') {
      await Message.deleteOne({ _id: messageId });
      return res.json({ message: 'Message deleted' });
    }
    
    await message.save();
    res.json({ message: 'Message moderated successfully', message });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

