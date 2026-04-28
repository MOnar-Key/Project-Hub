import mongoose from "mongoose";
// import { refreshToken } from "../controllers/auth.controller";

const sessionSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "users",
        required: [ true, "Refresh token hash is required" ]
    },
    refreshTokenHash: {
        type: String,
        required: [ true, "Refresh toekn hash is required" ]
    },
    ip: {
        type: String,
        required: [ true, "IP address is required" ]
    },
    userAgent: {
        type: String,
        required: [ true, " User agent is required" ]
    },
    revoked: {
type: Boolean,
default: false
    }
},
{
    timestamps: true
})

const sessionModel = new mongoose.model( "session", sessionSchema)

export default sessionModel