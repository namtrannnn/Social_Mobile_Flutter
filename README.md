# flutter_social_app

A Flutter social media application inspired by Instagram/Facebook, built with Flutter, Provider, REST API, Socket.IO, and secure local token storage.

---

## Current Features

### [AUTH]

- Register and login
- Logout
- Persistent login with secure token storage
- Auto-login session restore
- Protected screens based on authentication state
- Store current user information locally

### [POST]

- Display home feed
- Feed pagination / load more posts
- Create post with images
- Like / unlike post
- Double tap to like animation
- View users who liked a post
- Show post caption, author, location, and media
- Hide like count option
- Allow / disable comments per post
- Local UI update for post interactions

### [COMMENT SYSTEM]

- Create comments
- Reply to comments
- Nested replies
- Mention user when replying
- Edit own comments
- Delete comments
- Undo delete comment within a short time
- Like / unlike comments
- Pin / unpin comments by post owner
- Hide / unhide comments by post owner
- Disable / enable comments by post owner
- Sort comments by Newest / Oldest / Top
- Draggable comment bottom sheet
- Comment management bottom sheet
- Local comment count update for current user actions
- Show disabled-comment state when comments are turned off

### [NOTIFICATION]

- Display notification list
- Show unread notification badge
- Load unread notification count after login / app start
- Real-time notification updates with Socket.IO
- Add new notifications instantly when user is online
- Mark single notification as read
- Mark all notifications as read when opening notification screen
- Delete notifications
- Prevent duplicated real-time notifications
- Keep notification badge in sync with local UI state
- Support notification types with reference id and reference type
- Redis-based unread notification count caching on backend

---

## Planned Features

### [AUTH]

- Forgot password
- Change password
- Edit profile information
- Update avatar / cover image
- OAuth login
- Account verification

### [POST]

- Real upload progress tracking
- Video upload support
- Save draft posts
- Image crop & filters
- Drag & drop image reorder
- Background upload isolate
- Upload queue system
- Automatic image compression
- Offline retry upload
- Edit post
- Delete post
- Save / unsave posts
- Share posts
- Post report system

### [COMMENT SYSTEM]

- Real-time socket sync for comments
- Real-time comment count sync across users
- GIF / sticker comments
- Emoji reactions
- Voice comments
- Comment search
- Infinite reply pagination
- Keyword moderation
- AI toxic comment filtering
- Spam detection
- Comment notification system
- Admin moderation dashboard

### [NOTIFICATION]

- Notification settings
- Mute notification by type
- Push notifications
- Notification grouping
- Notification deep linking
- Notification pagination
- Notification filter by type
- Notification search
- Real-time notification read-state sync across devices
- Friend request notification actions
- Post like / comment / mention notifications
- Follow / friend activity notifications
- System announcement notifications

### [FRIEND SYSTEM]

- Send friend request
- Cancel sent friend request
- Accept friend request
- Decline friend request
- Remove friend
- Display friend request list
- Display sent request list
- Display friend list
- Friend request notification
- Friend status button: Add friend / Requested / Accept / Friends
- Real-time friend request updates with Socket.IO
- Sync friend status across profile and notification screens
