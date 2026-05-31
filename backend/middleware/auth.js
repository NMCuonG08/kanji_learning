const jwt = require('jsonwebtoken');
require('dotenv').config();

module.exports = function (req, res, next) {
  const authHeader = req.headers['authorization'];
  
  // Extract Bearer token
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Truy cập bị từ chối. Vui lòng cung cấp token đăng nhập!' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'kanji_master_super_jwt_secret_key_2026');
    req.user = decoded; // Attach decoded JWT payload (contains id and username)
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Mã xác thực JWT không hợp lệ hoặc đã hết hạn!' });
  }
};
