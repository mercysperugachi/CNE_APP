require('dotenv').config();
const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');

const app = express();

app.use(cors());
app.use(express.json());

// Configuración de Gmail
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// Ruta 1: Bienvenida y Clave Temporal
app.post('/api/auth/send-verification', async (req, res) => {
    const { email, userId } = req.body;

    if (!email) return res.status(400).json({ error: 'El correo es obligatorio' });

    try {
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: '✅ Alta en la Plataforma de Auditoría',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 25px; border: 1px solid #E2E8F0; border-radius: 12px; background-color: #F8FAFC;">
                    <h2 style="color: #0F172A;">Bienvenido al Sistema de Auditoría</h2>
                    <p style="color: #475569;">Sus credenciales han sido generadas con éxito para participar en la veeduría del proceso.</p>
                    <div style="background-color: #FFFFFF; padding: 15px; border-radius: 8px; text-align: center; margin: 20px 0; border: 1px dashed #CBD5E1;">
                        <p style="margin: 0; color: #64748B; font-size: 14px;">Clave de acceso temporal:</p>
                        <p style="margin: 10px 0 0 0; font-size: 22px; font-weight: bold; color: #D97706; letter-spacing: 1px;">Auditoria2026*</p>
                    </div>
                    <p style="color: #475569; font-size: 14px;">El sistema requerirá que personalice esta clave durante su primer inicio de sesión.</p>
                </div>
            `
        };

        await transporter.sendMail(mailOptions);
        res.status(200).json({ message: 'Correo enviado' });
    } catch (error) {
        console.error('Error enviando correo:', error);
        res.status(500).json({ error: 'Fallo al despachar el correo' });
    }
});

// Ruta 2: Recuperación de Contraseña
app.post('/api/auth/send-password-reset', async (req, res) => {
    const { email } = req.body;

    if (!email) return res.status(400).json({ error: 'El correo es obligatorio' });

    try {
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: '🔒 Solicitud de Restauración de Acceso',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 25px; border: 1px solid #E2E8F0; border-radius: 12px;">
                    <h2 style="color: #0F172A;">Restauración de Credenciales</h2>
                    <p style="color: #475569;">Se ha registrado una solicitud para recuperar el acceso a su cuenta.</p>
                    <p style="color: #475569;">Por protocolos de seguridad, contacte a su Supervisor Zonal para la emisión de una nueva clave temporal.</p>
                    <hr style="border: none; border-top: 1px solid #E2E8F0; margin: 25px 0;">
                    <p style="font-size: 11px; color: #94A3B8;">Si no realizó esta solicitud, desestime este mensaje.</p>
                </div>
            `
        };

        await transporter.sendMail(mailOptions);
        res.status(200).json({ message: 'Notificación enviada' });
    } catch (error) {
        console.error('Error enviando recuperación:', error);
        res.status(500).json({ error: 'Fallo al despachar el correo' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor activo en el puerto ${PORT}`);
});