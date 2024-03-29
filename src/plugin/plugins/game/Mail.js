import GamePlugin from '@plugin/GamePlugin'

import { hasProps, isNumber } from '@utils/validation'


export default class Mail extends GamePlugin {

    constructor(handler) {
        super(handler)

        this.events = {
            'send_mail': this.sendMail,
            'read_mail': this.readMail,
            'delete_mail': this.deleteMail,
            'delete_mail_from': this.deleteMailFrom
        }

        this.postcardCost = 10
        this.maxPostcards = 100

        this.responses = {
            InsufficientCoins: 0,
            FullInbox: 1,
            Success: 2
        }
    }

    sendMail(args, user) {
        if (!hasProps(args, 'recipient', 'postcardId')) return
        if (!isNumber(args.recipient) || !isNumber(args.postcardId)) return

        // Insufficient coins
        if (user.coins < this.postcardCost) {
            return this.sendMailResponse(user, this.responses.InsufficientCoins)
        }

        const recipient = this.usersById[args.recipient]

        if (recipient) {
            this.sendMailOnline(user, recipient, args.postcardId)
        } else {
            this.sendMailOffline(user, args.recipient, args.postcardId)
        }
    }

    readMail(args, user) {
        user.postcards.readMail()
    }

    deleteMail(args, user) {
        if (!hasProps(args, 'id')) return
        if (!isNumber(args.id)) return

        user.postcards.remove(args.id)
    }

    deleteMailFrom(args, user) {
        if (!hasProps(args, 'senderId')) return
        // null for system mail
        if (!isNumber(args.senderId) && args.senderId !== null) return

        user.postcards.removeFrom(args.senderId)
    }

    async sendMailOnline(user, recipient, postcardId) {
        // Ignored
        if (recipient.ignores.includes(user.id)) {
            return this.sendMailResponse(user, this.responses.Success)
        }

        // Full inbox
        if (recipient.postcards.count >= this.maxPostcards) {
            return this.sendMailResponse(user, this.responses.FullInbox)
        }

        // Add postcard
        const postcard = await recipient.postcards.add(user.id, postcardId)
        if (!postcard) return

        recipient.send('receive_mail', postcard)

        this.removeCoins(user)
    }

    async sendMailOffline(user, recipientId, postcardId) {
        const recipient = await this.db.getUserById(recipientId)
        if (!recipient) return

        // Ignored
        if (await this.db.getIgnored(recipientId, user.id)) {
            return this.sendMailResponse(user, this.responses.Success)
        }

        // Full inbox
        if (await this.db.getPostcardsCount(recipientId) >= this.maxPostcards) {
            return this.sendMailResponse(user, this.responses.FullInbox)
        }

        // Add postcard
        this.db.postcards.create({
            userId: recipientId,
            senderId: user.id,
            postcardId: postcardId
        })

        this.removeCoins(user)
    }

    removeCoins(user) {
        user.updateCoins(-this.postcardCost)
        this.sendMailResponse(user, this.responses.Success)
    }

    /**
     * Send response to the sending user.
     */
    sendMailResponse(user, response) {
        user.send('send_mail', { coins: user.coins, response: response })
    }

}
