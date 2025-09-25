require("dotenv").config();
const { connectDB } = require("./src/config/db");
const app = require("./src/app");
const http = require("http");
const localtunnel = require("localtunnel");
const User = require("./src/models/usersModel");

connectDB();

// Wrap Express app in HTTP server
const server = http.createServer(app);

// Initialize Socket.IO
const io = require("socket.io")(server, {
  cors: { origin: "*", methods: ["GET", "POST"] },
});

// Attach io to app for access in controllers
app.set("io", io);

// Handle new socket connections
io.on("connection", (socket) => {
  console.log("✅ New socket connected:", socket.id);

  // Join a private room using userId
  socket.on("joinRoom", (userId) => {
    socket.join(userId);
    console.log(`Socket ${socket.id} joined room ${userId}`);
  });

  socket.on("disconnect", () => {
    console.log("❌ Socket disconnected:", socket.id);
  });
});

// MongoDB Change Stream to emit coin updates in real-time
const coinsChangeStream = User.watch([], { fullDocument: "updateLookup" });
coinsChangeStream.on("change", (change) => {
  if (change.operationType === "update") {
    const updatedUser = change.fullDocument;
    const userId = updatedUser._id.toString();

    if (updatedUser.Coins !== undefined) {
      io.to(userId).emit("coin_update", { coins: updatedUser.Coins });
      console.log(`💰 Coins updated for user ${userId}: ${updatedUser.Coins}`);
    }
  }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, async () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);

 if (process.env.NODE_ENV !== "production") {
  try {
    const tunnel = await localtunnel({ port: PORT, subdomain: "kittyparty" });
    console.log(`🌍 Public URL: ${tunnel.url}`);

    // Set BASE_URL explicitly for dev
    process.env.BASE_URL = tunnel.url;

    tunnel.on("close", () => console.log("❌ Tunnel closed"));
  } catch (err) {
    console.error(
      "Tunnel failed. The subdomain may already be taken:",
      err.message
    );
  }
}
});
