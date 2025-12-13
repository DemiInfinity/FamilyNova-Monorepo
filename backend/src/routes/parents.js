const express = require('express');
const { auth, requireUserType } = require('../middleware/auth');
const User = require('../models/User');
const Message = require('../models/Message');

const router = express.Router();

// All routes require authentication and parent user type
router.use(auth);
router.use(requireUserType('parent'));

// @route   GET /api/parents/dashboard
// @desc    Get parent dashboard data
// @access  Private (Parent only)
router.get('/dashboard', async (req, res) => {
  try {
    const parent = await User.findById(req.user._id)
      .populate('children', 'profile verification friends lastLogin')
      .populate('parentConnections.parent', 'profile email');
    
    // Get recent activity from children
    const childrenActivity = await Message.find({
      $or: [
        { sender: { $in: parent.children } },
        { receiver: { $in: parent.children } }
      ]
    })
    .sort({ createdAt: -1 })
    .limit(20)
    .populate('sender receiver', 'profile displayName');
    
    res.json({
      parent: {
        id: parent._id,
        profile: parent.profile,
        children: parent.children,
        parentConnections: parent.parentConnections
      },
      recentActivity: childrenActivity
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/parents/children/:childId
// @desc    Get specific child's activity
// @access  Private (Parent only)
router.get('/children/:childId', async (req, res) => {
  try {
    const { childId } = req.params;
    
    // Verify child belongs to parent
    const parent = await User.findById(req.user._id);
    if (!parent.children.includes(childId)) {
      return res.status(403).json({ error: 'Child not found' });
    }
    
    const child = await User.findById(childId)
      .populate('friends', 'profile displayName verification');
    
    const messages = await Message.find({
      $or: [
        { sender: childId },
        { receiver: childId }
      ]
    })
    .sort({ createdAt: -1 })
    .limit(50)
    .populate('sender receiver', 'profile displayName');
    
    res.json({
      child: {
        id: child._id,
        profile: child.profile,
        verification: child.verification,
        friends: child.friends,
        lastLogin: child.lastLogin
      },
      messages
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/parents/connections
// @desc    Get parent connections (parents of child's friends)
// @access  Private (Parent only)
router.get('/connections', async (req, res) => {
  try {
    const parent = await User.findById(req.user._id)
      .populate('parentConnections.parent', 'profile email children');
    
    res.json({
      connections: parent.parentConnections.map(conn => ({
        parent: {
          id: conn.parent._id,
          profile: conn.parent.profile,
          email: conn.parent.email
        },
        connectedAt: conn.connectedAt
      }))
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

