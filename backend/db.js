const mysql = require('mysql2/promise');
require('dotenv').config();

// Create connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root_password_here',
  database: process.env.DB_NAME || 'kanji_learning',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

async function initDb() {
  let connection;
  let retries = 10;
  while (retries > 0) {
    try {
      connection = await pool.getConnection();
      console.log('Connected to MySQL Database Pool successfully.');
      break;
    } catch (err) {
      retries--;
      console.log(`Failed to connect to MySQL database. Retries left: ${retries}. Error: ${err.message}`);
      if (retries === 0) {
        throw err;
      }
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }

  try {
    // 1. Create users table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);
    console.log('Table "users" verified/created.');

    // 2. Create progress table (Kanji)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS progress (
        id INT AUTO_INCREMENT PRIMARY KEY,
        userId INT NOT NULL,
        kanjiId INT NOT NULL,
        correctCount INT DEFAULT 0,
        wrongCount INT DEFAULT 0,
        lastReviewed VARCHAR(50),
        masteryLevel INT DEFAULT 0,
        nextReviewAt VARCHAR(50),
        status VARCHAR(20) DEFAULT 'new',
        UNIQUE KEY user_kanji (userId, kanjiId),
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);
    console.log('Table "progress" (Kanji) verified/created.');

    // 3. Create vocab_progress table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS vocab_progress (
        id INT AUTO_INCREMENT PRIMARY KEY,
        userId INT NOT NULL,
        vocabId INT NOT NULL,
        lastCorrectAt VARCHAR(50),
        UNIQUE KEY user_vocab (userId, vocabId),
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);
    console.log('Table "vocab_progress" verified/created.');

    // 4. Create listening_progress table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS listening_progress (
        id INT AUTO_INCREMENT PRIMARY KEY,
        userId INT NOT NULL,
        questionId INT NOT NULL,
        completedAt VARCHAR(50),
        UNIQUE KEY user_listening (userId, questionId),
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);
    console.log('Table "listening_progress" verified/created.');

    // 5. Create grammar_progress table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS grammar_progress (
        id INT AUTO_INCREMENT PRIMARY KEY,
        userId INT NOT NULL,
        questionId INT NOT NULL,
        completedAt VARCHAR(50),
        UNIQUE KEY user_grammar (userId, questionId),
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);
    console.log('Table "grammar_progress" verified/created.');

  } catch (err) {
    console.error('Database initialization error:', err.message);
    throw err;
  } finally {
    if (connection) connection.release();
  }
}

module.exports = {
  pool,
  initDb
};
