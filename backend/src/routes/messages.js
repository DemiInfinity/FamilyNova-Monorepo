const express = require('express');
const { body, validationResult } = require('express-validator');
const { auth, requireUserType } = require('../middleware/auth');
const Message = require('../models/Message');
const User = require('../models/User');
const { getSupabase } = require('../config/database');

const router = express.Router();

// All routes require authentication
router.use(auth);

// @route   POST /api/messages
// @desc    Send a message (kids and parents)
// @access  Private
router.post('/', requireUserType('kid', 'parent'), [
  body('receiverId').notEmpty(),
  body('content').trim().isLength({ min: 1, max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { receiverId, content } = req.body;
    const supabase = await getSupabase();
    
    console.log(`[Messages] Sending message from ${req.user.id} (${req.user.userType}) to ${receiverId}`);
    
    // Verify receiver is a friend
    const receiver = await User.findById(receiverId);
    if (!receiver) {
      console.log(`[Messages] Receiver not found: ${receiverId}`);
      return res.status(404).json({ error: 'Receiver not found' });
    }
    
    console.log(`[Messages] Receiver found: ${receiver.id} (${receiver.userType})`);
    
    // Parents can only message other parents, kids can only message other kids
    if (req.user.userType === 'parent' && receiver.userType !== 'parent') {
      console.log(`[Messages] User type mismatch: parent trying to message ${receiver.userType}`);
      return res.status(403).json({ error: 'Parents can only message other parents' });
    }
    if (req.user.userType === 'kid' && receiver.userType !== 'kid') {
      console.log(`[Messages] User type mismatch: kid trying to message ${receiver.userType}`);
      return res.status(403).json({ error: 'Kids can only message other kids' });
    }
    
    // Check if they are friends - UUIDs are case-insensitive, use .eq
    const { data: friendships, error: friendError } = await supabase
      .from('friendships')
      .select('*')
      .or(`and(user_id.eq.${req.user.id},friend_id.eq.${receiverId}),and(user_id.eq.${receiverId},friend_id.eq.${req.user.id})`)
      .eq('status', 'accepted');
    
    if (friendError) {
      console.error('[Messages] Error checking friendship:', friendError);
      return res.status(500).json({ error: 'Failed to verify friendship' });
    }
    
    console.log(`[Messages] Found ${friendships?.length || 0} friendship(s) between ${req.user.id} and ${receiverId}`);
    
    if (!friendships || friendships.length === 0) {
      console.log(`[Messages] No accepted friendship found between ${req.user.id} and ${receiverId}`);
      // Check if there's a pending friendship
      const { data: pendingFriendships } = await supabase
        .from('friendships')
        .select('*')
        .or(`and(user_id.eq.${req.user.id},friend_id.eq.${receiverId}),and(user_id.eq.${receiverId},friend_id.eq.${req.user.id})`)
        .eq('status', 'pending');
      
      if (pendingFriendships && pendingFriendships.length > 0) {
        console.log(`[Messages] Found pending friendship - needs to be accepted first`);
        return res.status(403).json({ error: 'Friend request is pending. Please wait for acceptance.' });
      }
      
      return res.status(403).json({ error: 'Can only message friends. Please add this user as a friend first.' });
    }
    
    // Check monitoring level - full monitoring means all messages are flagged for review
    // Parents' messages are always approved
    const sender = await User.findById(req.user.id);
    const status = (sender.userType === 'parent' || sender.monitoringLevel !== 'full') ? 'approved' : 'pending';
    
    const message = await Message.create({
      senderId: req.user.id,
      receiverId: receiverId,
      content: content.trim(),
      status: status
    });
    
    // Get sender and receiver profiles for response
    const senderProfile = sender.profile || {};
    const receiverProfile = receiver.profile || {};
    
    res.status(201).json({
      message: {
        id: message.id,
        content: message.content,
        createdAt: message.createdAt ? new Date(message.createdAt).toISOString() : new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   GET /api/messages
// @desc    Get messages for current user
// @access  Private
router.get('/', async (req, res) => {
  try {
    const { conversationWith } = req.query;
    const supabase = await getSupabase();
    
    let query = supabase
      .from('messages')
      .select('*')
      .or(`sender_id.eq.${req.user.id},receiver_id.eq.${req.user.id}`);
    
    if (conversationWith) {
      query = supabase
        .from('messages')
        .select('*')
        .or(`and(sender_id.eq.${req.user.id},receiver_id.eq.${conversationWith}),and(sender_id.eq.${conversationWith},receiver_id.eq.${req.user.id})`);
    }
    
    query = query.order('created_at', { ascending: false }).limit(50);
    
    const { data: messagesData, error: messagesError } = await query;
    
    if (messagesError) {
      console.error('Error fetching messages:', messagesError);
      return res.status(500).json({ error: 'Failed to fetch messages' });
    }
    
    // Get unique sender and receiver IDs
    const userIds = new Set();
    if (messagesData) {
      messagesData.forEach(msg => {
        userIds.add(msg.sender_id);
        userIds.add(msg.receiver_id);
      });
    }
    
    // Fetch user profiles
    const userIdsArray = Array.from(userIds);
    const { data: usersData, error: usersError } = await supabase
      .from('users')
      .select('id, profile')
      .in('id', userIdsArray);
    
    const usersMap = new Map();
    if (!usersError && usersData) {
      usersData.forEach(user => {
        usersMap.set(user.id, user);
      });
    }
    
    // Mark messages as read if user is receiver
    if (messagesData && messagesData.length > 0) {
      const unreadMessageIds = messagesData
        .filter(msg => msg.receiver_id === req.user.id && msg.status !== 'approved')
        .map(msg => msg.id);
      
      if (unreadMessageIds.length > 0) {
        await supabase
          .from('messages')
          .update({ status: 'approved', moderated_at: new Date().toISOString() })
          .in('id', unreadMessageIds)
          .eq('receiver_id', req.user.id);
      }
    }
    
    // Format messages with user info
    const messages = (messagesData || []).reverse().map(msg => {
      const sender = usersMap.get(msg.sender_id);
      const receiver = usersMap.get(msg.receiver_id);
      const senderProfile = sender?.profile || {};
      const receiverProfile = receiver?.profile || {};
      
      return {
        id: msg.id,
        content: msg.content,
        status: msg.status,
        sender: {
          id: msg.sender_id,
          profile: {
            displayName: senderProfile.displayName || 'Unknown',
            avatar: senderProfile.avatar
          }
        },
        receiver: {
          id: msg.receiver_id,
          profile: {
            displayName: receiverProfile.displayName || 'Unknown',
            avatar: receiverProfile.avatar
          }
        },
        createdAt: msg.created_at,
        updatedAt: msg.updated_at
      };
    });
    
    res.json({ messages });
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// @route   PUT /api/messages/:messageId/moderate
// @desc    Moderate a message (parents only)
// @access  Private (Parent only)
router.put('/:messageId/moderate', requireUserType('parent'), async (req, res) => {
  try {
    const { messageId } = req.params;
    const { action } = req.body; // 'approve', 'reject', 'delete'
    const supabase = await getSupabase();
    
    const message = await Message.findById(messageId);
    
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }
    
    // Verify parent has access to this message (child is sender or receiver)
    const { data: parentChildren, error: childrenError } = await supabase
      .from('parent_children')
      .select('child_id')
      .eq('parent_id', req.user.id);
    
    if (childrenError) {
      return res.status(500).json({ error: 'Failed to verify access' });
    }
    
    const childIds = parentChildren ? parentChildren.map(c => c.child_id) : [];
    const hasAccess = childIds.includes(message.senderId) || childIds.includes(message.receiverId);
    
    if (!hasAccess) {
      return res.status(403).json({ error: 'No access to this message' });
    }
    
    if (action === 'delete') {
      await supabase
        .from('messages')
        .delete()
        .eq('id', messageId);
      
      return res.json({ message: 'Message deleted' });
    }
    
    if (action === 'approve') {
      message.status = 'approved';
      message.moderatedBy = req.user.id;
      message.moderatedAt = new Date();
    } else if (action === 'reject') {
      message.status = 'rejected';
      message.moderatedBy = req.user.id;
      message.moderatedAt = new Date();
    }
    
    await message.save();
    
    res.json({ 
      message: 'Message moderated successfully',
      message: {
        id: message.id,
        status: message.status,
        moderatedBy: message.moderatedBy,
        moderatedAt: message.moderatedAt
      }
    });
  } catch (error) {
    console.error('Error moderating message:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
