const nodemailer = require("nodemailer");
const logger = require("./logger");

const smtpHost = process.env.SMTP_HOST || "smtp.mailtrap.io";
const smtpPort = Number(process.env.SMTP_PORT || 2525);
const smtpUser = process.env.SMTP_USER;
const smtpPass = process.env.SMTP_PASS;
const smtpSecure = process.env.SMTP_SECURE === "true" || smtpPort === 465;
const emailFrom = process.env.EMAIL_FROM || (smtpUser ? `"BigPharma" <${smtpUser}>` : '"BigPharma" <noreply@bigpharma.com>');
const appUrl = process.env.APP_URL || "https://example.com";
const passwordResetUrlTemplate = process.env.PASSWORD_RESET_URL || `${appUrl}/reset-password?token={{token}}`;

const isConfigured = Boolean(smtpHost && smtpPort && smtpUser && smtpPass);

const transporter = isConfigured
  ? nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpSecure,
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
      tls: {
        rejectUnauthorized: process.env.SMTP_REJECT_UNAUTHORIZED !== "false",
      },
    })
  : null;

const formatTemplate = (template, data) =>
  Object.keys(data).reduce(
    (result, key) => result.replace(new RegExp(`{{${key}}}`, "g"), data[key]),
    template
  );

const getPasswordResetLink = (token) => {
  if (!token) return appUrl;
  if (passwordResetUrlTemplate.includes("{{token}}")) {
    return formatTemplate(passwordResetUrlTemplate, { token: encodeURIComponent(token) });
  }
  const separator = passwordResetUrlTemplate.includes("?") ? "&" : "?";
  return `${passwordResetUrlTemplate}${separator}token=${encodeURIComponent(token)}`;
};

const wrapHtml = (content) => `
  <div style="font-family: Arial, sans-serif; color: #333; line-height: 1.5;">
    <div style="max-width: 680px; margin: 0 auto; padding: 24px; background-color: #f7f7f7;">
      <div style="background: #ffffff; border-radius: 8px; padding: 24px; box-shadow: 0 0 12px rgba(0,0,0,0.05);">
        ${content}
      </div>
      <p style="font-size: 13px; color: #777; margin-top: 18px;">Cet e-mail a été envoyé par BigPharma. Si vous n'attendiez pas ce message, ignorez-le simplement.</p>
    </div>
  </div>
`;

const buildEmailHtml = ({ greeting, intro, bullets = [], actionText, actionUrl, outro }) => {
  const bulletHtml = bullets.length
    ? `<ul style="padding-left: 18px; margin: 16px 0;">${bullets
        .map((line) => `<li style="margin-bottom: 8px;">${line}</li>`)
        .join("")}</ul>`
    : "";

  const actionHtml = actionText && actionUrl
    ? `<p><a href="${actionUrl}" style="display: inline-block; padding: 12px 20px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 5px;">${actionText}</a></p>`
    : "";

  const html = `
    <h1 style="font-size: 22px; margin-bottom: 12px; color: #1a1a1a;">${greeting}</h1>
    <p style="font-size: 16px; margin-bottom: 16px;">${intro}</p>
    ${bulletHtml}
    ${actionHtml}
    <p style="font-size: 15px; margin-top: 18px; color: #555;">${outro || "Merci de votre confiance.\nL'équipe BigPharma"}</p>
  `;

  return wrapHtml(html);
};

const buildEmailText = ({ greeting, intro, bullets = [], actionText, actionUrl, outro }) => {
  const bulletText = bullets.length ? bullets.map((line) => `- ${line}`).join("\n") + "\n" : "";
  const actionTextBlock = actionText && actionUrl ? `\n${actionText}: ${actionUrl}\n` : "";

  return [greeting, "", intro, "", bulletText, actionTextBlock, outro || "Merci de votre confiance.\nL'équipe BigPharma"].filter(Boolean).join("\n");
};

const sendMail = async ({ to, subject, text, html }) => {
  if (process.env.NODE_ENV === "test") {
    logger.info(`MailService: test environment detected, skipping actual email sending to ${to} (mocked success)`);
    return true;
  }

  if (!to) {
    logger.warn("MailService: missing recipient address");
    return false;
  }

  if (!isConfigured) {
    logger.warn(`MailService: SMTP configuration not available, skipping email to ${to}`);
    return false;
  }

  try {
    const sent = await transporter.sendMail({
      from: emailFrom,
      to,
      subject,
      text,
      html,
    });
    logger.info(`Email sent to ${to} | subject=${subject} | messageId=${sent.messageId}`);
    return true;
  } catch (error) {
    logger.error(`MailService: failed to send email to ${to}`, error);
    return false;
  }
};

const sendTemplateEmail = async ({ to, subject, greeting, intro, bullets, actionText, actionUrl, outro }) => {
  const text = buildEmailText({ greeting, intro, bullets, actionText, actionUrl, outro });
  const html = buildEmailHtml({ greeting, intro, bullets, actionText, actionUrl, outro });

  return sendMail({ to, subject, text, html });
};

const sendStaffWelcomeEmail = async ({ email, fullName, companyName }) =>
  sendTemplateEmail({
    to: email,
    subject: "Votre compte BigPharma a été créé",
    greeting: `Bonjour ${fullName},`,
    intro: `Votre compte a été créé avec succès pour la pharmacie ${companyName}. Vous pouvez maintenant vous connecter à l'application.`,
    bullets: [
      `Adresse e-mail : ${email}`,
      "Pour des raisons de sécurité, votre mot de passe n'est pas affiché ici.",
      "Si vous n'avez pas encore défini de mot de passe, utilisez la fonction de réinitialisation de mot de passe.",
    ],
    actionText: "Se connecter à BigPharma",
    actionUrl: appUrl,
    outro: "Si vous rencontrez des problèmes, contactez votre administrateur.",
  });

const sendClientWelcomeEmail = async ({ email, fullName, companyName }) =>
  sendTemplateEmail({
    to: email,
    subject: "Bienvenue chez BigPharma",
    greeting: `Bonjour ${fullName},`,
    intro: `Merci de vous être inscrit sur l'application client de ${companyName}. Votre compte est maintenant actif.`,
    bullets: [
      `Adresse e-mail : ${email}`,
      "Utilisez votre mot de passe pour vous connecter.",
      "Si vous avez oublié votre mot de passe, utilisez la fonction de réinitialisation.",
    ],
    actionText: "Accéder à votre compte",
    actionUrl: appUrl,
    outro: "Nous vous remercions de votre confiance.",
  });

const sendPasswordResetEmail = async ({ email, fullName, token }) => {
  const html = wrapHtml(`
    <h1 style="font-size: 22px; margin-bottom: 12px; color: #1a1a1a;">Bonjour ${fullName || ""},</h1>
    <p style="font-size: 16px; margin-bottom: 16px;">
      Vous avez demandé la réinitialisation de votre mot de passe BigPharma.<br>
      Utilisez le code ci-dessous dans l'application. Il est valable <strong>15 minutes</strong>.
    </p>
    <div style="text-align: center; margin: 32px 0;">
      <div style="display: inline-block; background: #f0f4ff; border: 2px dashed #6366f1; border-radius: 12px; padding: 24px 48px;">
        <p style="margin: 0 0 8px 0; font-size: 13px; color: #6366f1; text-transform: uppercase; letter-spacing: 2px; font-weight: 600;">Votre code de réinitialisation</p>
        <p style="margin: 0; font-size: 42px; font-weight: 800; letter-spacing: 8px; color: #1a1a1a; font-family: monospace;">${token}</p>
      </div>
    </div>
    <p style="font-size: 14px; color: #777; margin-top: 16px;">
      ⚠️ Si vous n'avez pas demandé cette réinitialisation, ignorez cet email. Votre mot de passe actuel reste inchangé.
    </p>
    <p style="font-size: 15px; margin-top: 18px; color: #555;">Merci de votre confiance.<br>L'équipe BigPharma</p>
  `);

  const text = [
    `Bonjour ${fullName || ""},`,
    "",
    "Votre code de réinitialisation de mot de passe BigPharma :",
    "",
    `  CODE : ${token}`,
    "",
    "Ce code est valable 15 minutes.",
    "Si vous n'avez pas fait cette demande, ignorez cet email.",
    "",
    "L'équipe BigPharma",
  ].join("\n");

  return sendMail({
    to: email,
    subject: `${token} — Votre code de réinitialisation BigPharma`,
    text,
    html,
  });
};

const sendOrderConfirmationEmail = async ({ email, fullName, orderNumber, pickupMode, companyName, collectionCode }) =>
  sendTemplateEmail({
    to: email,
    subject: `Confirmation de commande ${orderNumber}`,
    greeting: `Bonjour ${fullName},`,
    intro: `Votre commande ${orderNumber} a bien été enregistrée chez ${companyName}. Nous la préparons dès maintenant.`, 
    bullets: [
      `Mode de retrait : ${pickupMode || "sur place"}`,
      `Code de collecte : ${collectionCode || "N/A"}`,
    ],
    actionText: "Voir ma commande",
    actionUrl: appUrl,
    outro: "Nous vous informerons des prochaines étapes dès que votre commande évoluera.",
  });

const sendOrderStatusUpdateEmail = async ({ email, fullName, orderNumber, statusLabel, companyName }) =>
  sendTemplateEmail({
    to: email,
    subject: `Commande ${orderNumber} : ${statusLabel}`,
    greeting: `Bonjour ${fullName},`,
    intro: `Le statut de votre commande ${orderNumber} chez ${companyName} a été mis à jour.`, 
    bullets: [
      `Nouveau statut : ${statusLabel}`,
      "Vous pouvez suivre l'évolution de votre commande depuis votre espace client.",
    ],
    actionText: "Voir ma commande",
    actionUrl: appUrl,
    outro: "Merci pour votre confiance.",
  });

const sendInvoiceReadyEmail = async ({ email, fullName, invoiceNumber, orderNumber, companyName }) =>
  sendTemplateEmail({
    to: email,
    subject: `Facture ${invoiceNumber} disponible`, 
    greeting: `Bonjour ${fullName},`,
    intro: `La facture ${invoiceNumber} de votre commande ${orderNumber} chez ${companyName} est désormais disponible.`, 
    bullets: [
      "Vous pouvez la télécharger depuis votre espace client.",
      "Conservez cette facture pour vos archives.",
    ],
    actionText: "Voir ma facture",
    actionUrl: appUrl,
    outro: "Merci d'utiliser BigPharma.",
  });

const sendSupportResponseEmail = async ({ email, fullName, subject, companyName }) =>
  sendTemplateEmail({
    to: email,
    subject: `Réponse du support : ${subject}`,
    greeting: `Bonjour ${fullName},`,
    intro: "La pharmacie a répondu à votre demande de support.",
    bullets: [
      `Sujet : ${subject}`,
      "Connectez-vous pour lire la réponse complète.",
    ],
    actionText: "Voir ma demande", 
    actionUrl: appUrl,
    outro: "Nous restons à votre disposition.",
  });

const sendComplaintStatusEmail = async ({ email, fullName, complaintNumber, status, companyName }) =>
  sendTemplateEmail({
    to: email,
    subject: `Mise à jour réclamation ${complaintNumber}`,
    greeting: `Bonjour ${fullName},`,
    intro: `Le statut de votre réclamation ${complaintNumber} chez ${companyName} a été mis à jour.`, 
    bullets: [
      `Nouveau statut : ${status}`,
      "Vous pouvez consulter les détails de la réclamation depuis votre compte.",
    ],
    actionText: "Voir ma réclamation",
    actionUrl: appUrl,
    outro: "Merci de votre patience.",
  });

const sendProfileUpdateEmail = async ({ email, fullName }) =>
  sendTemplateEmail({
    to: email,
    subject: "Votre profil BigPharma a été mis à jour",
    greeting: `Bonjour ${fullName},`,
    intro: "Votre profil a été modifié avec succès sur votre compte BigPharma.",
    bullets: [
      "Vos informations personnelles ont été mises à jour.",
      "Si vous n'êtes pas à l'origine de cette modification, contactez immédiatement le support.",
    ],
    actionText: "Accéder à mon compte",
    actionUrl: appUrl,
    outro: "Pour toute question, notre équipe est disponible.",
  });

const sendPasswordChangedEmail = async ({ email, fullName }) =>
  sendTemplateEmail({
    to: email,
    subject: "Votre mot de passe BigPharma a été modifié",
    greeting: `Bonjour ${fullName},`,
    intro: "Votre mot de passe a été modifié avec succès.",
    bullets: [
      "Si vous êtes à l'origine de cette action, vous pouvez ignorer ce message.",
      "Si vous n'avez pas effectué ce changement, réinitialisez immédiatement votre mot de passe et contactez le support.",
    ],
    actionText: "Réinitialiser mon mot de passe",
    actionUrl: appUrl,
    outro: "Votre sécurité est notre priorité.",
  });

module.exports = {
  sendMail,
  sendStaffWelcomeEmail,
  sendClientWelcomeEmail,
  sendPasswordResetEmail,
  sendProfileUpdateEmail,
  sendPasswordChangedEmail,
  sendOrderConfirmationEmail,
  sendOrderStatusUpdateEmail,
  sendInvoiceReadyEmail,
  sendSupportResponseEmail,
  sendComplaintStatusEmail,
  isConfigured,
};
