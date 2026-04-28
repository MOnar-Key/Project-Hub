import { Router } from "express";
import * as authController from "../controllers/auth.controller.js";
const authRouter = Router();

/**
 * GET /api/auth/login
 */
authRouter.post("/login", authController.login)

/**
 * POST /api/auth/register
 */
authRouter.post("/register", authController.register);

/**
 * GET /api/auth/get-me
 */
authRouter.get("/get-me", authController.getMe)

/**
 * GET /api/auth/refresh-token
 */
authRouter.get("/refresh-token",authController.refreshToken)

/**
 * GET /api/auth/layout
 */
authRouter.get("/logout", authController.logout)

/**
 *  GET /api/auth/logout-all
 */
authRouter.get("/logout-all",authController.logoutAll)

/**
 * GET /api/auth/verified
 */
 authRouter.get("/verify-email", authController.verifyEmail)
 
export default authRouter;
