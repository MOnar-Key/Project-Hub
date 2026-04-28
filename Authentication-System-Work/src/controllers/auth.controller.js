
import userModel from "../models/user.model.js";
import crypto, { verify } from "crypto";
import jwt from "jsonwebtoken";
import config from "../config/config.js";
import sessionModel from "../models/session.model.js";
import { startSession } from "mongoose";
import { sendEmail } from "../services/email.service.js";
import { send } from "process";
import { genrateOtp, getOtpHtml } from "../utils/otpgenrate.js";
import otpModel from "../models/otp.model.js";

export async function register(req, res){
    const { username, email, password} = req.body;

    const isAlreadyRegistered = await userModel.findOne[{
        $or: [
            { username },
            { email }
        ]
    }]

    if (isAlreadyRegistered) {
        res.status(409).json({
            message: "Username or email already exists"
        })
    }

    const hashedPassword = crypto.createHash("sha256").update(password).digest("hex");

    const user = await userModel.create({
        username,
        email,
        password: hashedPassword
    })
    const otp = genrateOtp();
    const html = getOtpHtml(otp);
     const otpHash = crypto.createHash("sha256").update(otp).digest("hex");
     await otpModel.create({
        email,
        user: user._id,
        otpHash
     })
   await sendEmail(email, "OTP Verification", `Your OTP code is ${otp}`, html)

  res.status(201).json({
    message: "User registered successfully",
    user:{
        username: user.username,
        email: user.email,
        verified: user.verified
    },
  })  
}

export async function login(req, res){
    const {email, password} = req.body;
    const user = await userModel.findOne({ email })

    if(!user){
        res.status(401).json({
            message: "Invalid email or password"
        })
    }
    if(!user.verified){
        return res.status(401).json({
            message: "Email not verified"
        })
    }
    const hashedPassword = crypto.createHash("sha256").update(password).digest("hex");
    const isPasswordValid = hashedPassword === user.password;
    if(!isPasswordValid){
        return res.status(401).json({
            message:"Invalid email or password"
        })
    }
    const refreshToken = jwt.sign({
        id: user.id
    },config.JWT_SECRET,
{
    expiresIn: "7d"
})
const refreshTokenHash = crypto.createHash("sha256").update(refreshToken).digest("hex");
const session = await sessionModel.create({
    user: user._id,
    refreshTokenHash,
    ip: req.ip,
    userAgent: req.headers[ "user-agent"]
})
 const accessToken = jwt.sign({
    id: user._id,
    session: session._id
 }, config.JWT_SECRET,{
    expiresIn: "15m"
 })
 res.cookie("refreshToken", refreshToken,{
    httpOnly: true,
    secure: true,
    sameSite: "strict",
    maxAgent: 7* 24* 60* 60* 1000
 })
 res.status(200).json({
    message: "Logged in successfully",

    user: {
        username: user.username,
        email: user.email,
    }, 
    accessToken,
 })
} 

 export async function getMe(req, res) {
    try{
        const token = req.headers.authorization?.split(" ")[1];

    if(!token){
        return res.status(401).json({
            message:"token not found"
        });
    }

    const decoded = jwt.verify(token, config.JWT_SECRET);
    const user = await userModel.findById(decoded.id).select("-password");

    res.status(200).json({
       success: true, user
    });
} catch (err) {          
    res.status(500).json({ message: err.message });
}

}

 export async function refreshToken(req, res){
  
 const refreshToken= req.cookies.refreshToken;

  if(!refreshToken){
    return res.status(401).json({
        message: "refreshToekn not found"
    })
    
  }
  const refreshTokenHash = crypto.createHash("sha256").update(refreshToken).digest("hex");

  const session = await sessionModel.findOne({
    refreshTokenHash,
    revoked: false
  })
  if(!session)
{
      return res.status(401).json({
        message: "Invalid refresh token"
      })
}  
   
  const decoded= jwt.verify(refreshToken, config.JWT_SECRET)

    const accessToken = jwt.sign({
        id: decoded.id
    }, config.JWT_SECRET,
    {
        expiresIn: "15m"
    }
)
  const newRefreshToken = jwt.sign({
    id: decoded.id
  }, config.JWT_SECRET,{
    expiresIn: "7d"
  }
)

session.refreshTokenHash = newRefreshTokenHash;
await session.save();

res.cookie("refreshToken", newRefreshToken,{
    httpOnly: true,
    secure: true,
sameSite: "strict",
maxAge: 7*24*60*60*1000
})
res.status(200).json({
    message: "Access Token Refreshed succesfully",
    accessToken  
})

}

 export async function logout(req,res){
    const refreshToken = req.cookies.refreshToken;
    if(!refreshToken){
        return  res.status(400).json({
            message: "refesh token not found"
        })
    }
    const refreshTokenHash = crypto.createHash("sha256").update(refreshToken).digest("hex");
    await sessionModel.findOneAndUpdate({
        refreshTokenHash
    },{
        revoked: true
    })
    if(!session){
        return res.status(400).json({
            message: "Invalid refresh token"
        })
    }
    session.revoked = true;
    await session.save();

    res.clearcookie("refreshToken")
    res.status(200).json({
            message: "logged out successfully"
    })    
}

 export async function logoutAll(req, res){
    const refreshToken = req.cookies.refreshToken;
    if(!refreshToken) {
        return res.status(400).json({
            message: "refresh token not found"
        })
    }
    const  decoded = jwt.verify(refreshToken, config.JWT_SECRET)
    await sessionModel.updateMany({
        user: decoded.id,
        revoked: false
    },
{
    revoked: true
})
res.clearcookie("refreshToken")
res.status(200).json({
    message: "Logout out from all devices successfully"
})
}

export async function verifyEmail(req, res) {
    const { otp, email } = req.body

    const otpHash = crypto.createHash("sha256").update(otp).digest("hex");

    const otpDoc = await otpModel.findOne({
        email,
        otpHash
    })

    if (!otpDoc) {
        return res.status(400).json({
            message: "Invalid OTP"
        })
    }

    const user = await userModel.findByIdAndUpdate(otpDoc.user, {
        verified: true
    })

    await otpModel.deleteMany({
        user: otpDoc.user
    })

    return res.status(200).json({
        message: "Email verified successfully",
        user: {
            username: user.username,
            email: user.email,
            verified: user.verified
        }
    })
}