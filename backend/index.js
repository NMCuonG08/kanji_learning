const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool, initDb } = require('./db');
const auth = require('./middleware/auth');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'kanji_master_super_jwt_secret_key_2026';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize DB and launch server
initDb().then(() => {
  app.listen(PORT, () => {
    console.log(`Kanji Master Backend running on port ${PORT}`);
  });
}).catch(err => {
  console.error('Failed to initialize database, exiting...', err);
  process.exit(1);
});

// === Authentication Routes ===

// 1. Register User
app.post('/api/auth/register', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ error: 'Tên đăng nhập và mật khẩu không được bỏ trống!' });
  }

  try {
    // Check if user already exists
    const [existing] = await pool.query('SELECT id FROM users WHERE username = ?', [username]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Tài khoản đã tồn tại trên hệ thống!' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const [result] = await pool.query(
      'INSERT INTO users (username, password) VALUES (?, ?)',
      [username, hashedPassword]
    );

    const userId = result.insertId;

    // Generate JWT Token (valid for 30 days)
    const token = jwt.sign({ id: userId, username }, JWT_SECRET, { expiresIn: '30d' });

    res.status(201).json({
      message: 'Đăng ký tài khoản thành công!',
      token,
      user: { id: userId, username }
    });

  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ error: 'Có lỗi xảy ra trong quá trình đăng ký!' });
  }
});

// 2. Login User
app.post('/api/auth/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ error: 'Vui lòng cung cấp đầy đủ tên đăng nhập và mật khẩu!' });
  }

  try {
    // Query user
    const [users] = await pool.query('SELECT * FROM users WHERE username = ?', [username]);
    if (users.length === 0) {
      return res.status(400).json({ error: 'Tài khoản hoặc mật khẩu không chính xác!' });
    }

    const user = users[0];

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Tài khoản hoặc mật khẩu không chính xác!' });
    }

    // Generate JWT Token
    const token = jwt.sign({ id: user.id, username: user.username }, JWT_SECRET, { expiresIn: '30d' });

    res.status(200).json({
      message: 'Đăng nhập thành công!',
      token,
      user: { id: user.id, username: user.username }
    });

  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Có lỗi xảy ra trong quá trình đăng nhập!' });
  }
});

// === Protected Progress Synchronization Routes ===

// 3. GET Kanji Progress
app.get('/api/kanji-progress', auth, async (req, res) => {
  const userId = req.user.id;
  try {
    const [rows] = await pool.query(
      `SELECT kanjiId, correctCount, wrongCount, lastReviewed, masteryLevel, nextReviewAt, status 
       FROM progress WHERE userId = ?`,
      [userId]
    );

    // Format output as a Map of kanjiId -> entry map
    const result = {};
    rows.forEach(row => {
      result[row.kanjiId] = {
        kanjiId: row.kanjiId,
        correctCount: row.correctCount,
        wrongCount: row.wrongCount,
        lastReviewed: row.lastReviewed,
        masteryLevel: row.masteryLevel,
        nextReviewAt: row.nextReviewAt,
        status: row.status
      };
    });

    res.status(200).json(result);
  } catch (err) {
    console.error('Get Kanji progress error:', err);
    res.status(500).json({ error: 'Lỗi tải dữ liệu tiến trình Kanji!' });
  }
});

// 4. POST Save/Update Kanji Progress
app.post('/api/kanji-progress', auth, async (req, res) => {
  const userId = req.user.id;
  const { kanjiId, correctCount, wrongCount, lastReviewed, masteryLevel, nextReviewAt, status } = req.body;

  if (kanjiId === undefined) {
    return res.status(400).json({ error: 'Thiếu thông số kanjiId!' });
  }

  try {
    await pool.query(
      `INSERT INTO progress 
       (userId, kanjiId, correctCount, wrongCount, lastReviewed, masteryLevel, nextReviewAt, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?) 
       ON DUPLICATE KEY UPDATE 
         correctCount = VALUES(correctCount),
         wrongCount = VALUES(wrongCount),
         lastReviewed = VALUES(lastReviewed),
         masteryLevel = VALUES(masteryLevel),
         nextReviewAt = VALUES(nextReviewAt),
         status = VALUES(status)`,
      [userId, kanjiId, correctCount || 0, wrongCount || 0, lastReviewed, masteryLevel || 0, nextReviewAt, status || 'learning']
    );

    res.status(200).json({ message: 'Lưu tiến trình Kanji thành công!' });
  } catch (err) {
    console.error('Save Kanji progress error:', err);
    res.status(500).json({ error: 'Lỗi đồng bộ dữ liệu tiến trình Kanji!' });
  }
});

// 5. GET Vocabulary Progress
app.get('/api/vocab-progress', auth, async (req, res) => {
  const userId = req.user.id;
  try {
    const [rows] = await pool.query(
      'SELECT vocabId, lastCorrectAt FROM vocab_progress WHERE userId = ?',
      [userId]
    );

    // Format output as a Map of vocabId -> timestamp
    const result = {};
    rows.forEach(row => {
      result[row.vocabId] = row.lastCorrectAt;
    });

    res.status(200).json(result);
  } catch (err) {
    console.error('Get vocab progress error:', err);
    res.status(500).json({ error: 'Lỗi tải dữ liệu tiến trình từ vựng!' });
  }
});

// 6. POST Save Vocabulary Progress
app.post('/api/vocab-progress', auth, async (req, res) => {
  const userId = req.user.id;
  const { vocabId, lastCorrectAt } = req.body;

  if (vocabId === undefined) {
    return res.status(400).json({ error: 'Thiếu thông số vocabId!' });
  }

  const timestamp = lastCorrectAt || new Date().toISOString();

  try {
    await pool.query(
      `INSERT INTO vocab_progress (userId, vocabId, lastCorrectAt) 
       VALUES (?, ?, ?) 
       ON DUPLICATE KEY UPDATE lastCorrectAt = VALUES(lastCorrectAt)`,
      [userId, vocabId, timestamp]
    );

    res.status(200).json({ message: 'Lưu tiến trình từ vựng thành công!' });
  } catch (err) {
    console.error('Save vocab progress error:', err);
    res.status(500).json({ error: 'Lỗi đồng bộ tiến trình từ vựng!' });
  }
});

// 7. DELETE Vocabulary Progress
app.delete('/api/vocab-progress/:vocabId', auth, async (req, res) => {
  const userId = req.user.id;
  const vocabId = parseInt(req.params.vocabId);

  if (isNaN(vocabId)) {
    return res.status(400).json({ error: 'Mã từ vựng vocabId không hợp lệ!' });
  }

  try {
    await pool.query(
      'DELETE FROM vocab_progress WHERE userId = ? AND vocabId = ?',
      [userId, vocabId]
    );
    res.status(200).json({ message: 'Xóa tiến trình từ vựng thành công!' });
  } catch (err) {
    console.error('Delete vocab progress error:', err);
    res.status(500).json({ error: 'Lỗi xóa tiến trình từ vựng!' });
  }
});

// 8. GET Listening Progress
app.get('/api/listening-progress', auth, async (req, res) => {
  const userId = req.user.id;
  try {
    const [rows] = await pool.query(
      'SELECT questionId FROM listening_progress WHERE userId = ?',
      [userId]
    );

    const result = rows.map(row => row.questionId);
    res.status(200).json(result);
  } catch (err) {
    console.error('Get listening progress error:', err);
    res.status(500).json({ error: 'Lỗi tải tiến trình bài nghe N5!' });
  }
});

// 9. POST Save Listening Progress
app.post('/api/listening-progress', auth, async (req, res) => {
  const userId = req.user.id;
  const { questionId } = req.body;

  if (questionId === undefined) {
    return res.status(400).json({ error: 'Thiếu thông số questionId!' });
  }

  const timestamp = new Date().toISOString();

  try {
    await pool.query(
      'INSERT IGNORE INTO listening_progress (userId, questionId, completedAt) VALUES (?, ?, ?)',
      [userId, questionId, timestamp]
    );
    res.status(200).json({ message: 'Lưu tiến trình bài nghe thành công!' });
  } catch (err) {
    console.error('Save listening progress error:', err);
    res.status(500).json({ error: 'Lỗi đồng bộ tiến trình bài nghe!' });
  }
});

// 10. GET Grammar Progress
app.get('/api/grammar-progress', auth, async (req, res) => {
  const userId = req.user.id;
  try {
    const [rows] = await pool.query(
      'SELECT questionId FROM grammar_progress WHERE userId = ?',
      [userId]
    );

    const result = rows.map(row => row.questionId);
    res.status(200).json(result);
  } catch (err) {
    console.error('Get grammar progress error:', err);
    res.status(500).json({ error: 'Lỗi tải tiến trình trắc nghiệm ngữ pháp N5!' });
  }
});

// 11. POST Save Grammar Progress
app.post('/api/grammar-progress', auth, async (req, res) => {
  const userId = req.user.id;
  const { questionId } = req.body;

  if (questionId === undefined) {
    return res.status(400).json({ error: 'Thiếu thông số questionId!' });
  }

  const timestamp = new Date().toISOString();

  try {
    await pool.query(
      'INSERT IGNORE INTO grammar_progress (userId, questionId, completedAt) VALUES (?, ?, ?)',
      [userId, questionId, timestamp]
    );
    res.status(200).json({ message: 'Lưu tiến trình trắc nghiệm ngữ pháp thành công!' });
  } catch (err) {
    console.error('Save grammar progress error:', err);
    res.status(500).json({ error: 'Lỗi đồng bộ tiến trình trắc nghiệm ngữ pháp!' });
  }
});

// 12. POST Reset All User Progress
app.post('/api/reset-progress', auth, async (req, res) => {
  const userId = req.user.id;
  try {
    await pool.query('DELETE FROM progress WHERE userId = ?', [userId]);
    await pool.query('DELETE FROM vocab_progress WHERE userId = ?', [userId]);
    await pool.query('DELETE FROM listening_progress WHERE userId = ?', [userId]);
    await pool.query('DELETE FROM grammar_progress WHERE userId = ?', [userId]);

    res.status(200).json({ message: 'Đặt lại toàn bộ tiến trình học thành công!' });
  } catch (err) {
    console.error('Reset progress error:', err);
    res.status(500).json({ error: 'Lỗi khi đặt lại toàn bộ tiến trình học tập!' });
  }
});
