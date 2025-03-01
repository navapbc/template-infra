
export interface EmailHeader{
    id: string;
    to: EmailAddress;
    from: string;
    subject: string;
}

export interface EmailContent{
    text: string;
    html: string;
    emailHeader: EmailHeader;
}

export type EmailAddress = `${string}@${string}.${string}`;

export abstract class EmailService {

  /*
  * Generate a random email address
  */
  abstract generateEmailAddress(): EmailAddress;

  /*
  * Get EmailContent associated with an Email
  */
  abstract getEmailContent(email: EmailHeader): Promise<EmailContent>;

  /*
  * Get all emails sent to an email address
  */
  abstract getInbox(emailAddress: EmailAddress): Promise<EmailHeader[]>;

  /*
  * Return the first email sent to an email address that contains a specific subject sent. Waits for the email for a default amount of time before timing out.
  */
  abstract waitForEmailWithSubject(emailAddress : EmailAddress, subjectSubstring : string): Promise<EmailContent>;

  /*
  * Get a random base 36 alphanumeric string.
  * Used for creating a test email address.
  */
  protected randomString(length: number): string {
    const numBytes = Math.ceil(length * 2);
    return Array.from(crypto.getRandomValues(new Uint8Array(numBytes)))
      .map((b) => b.toString(36))
      .join('')
      .slice(0, length);
  }
}
