import React from 'react';

import {
    TextField,
    Dialog,
    Button,
    DialogTitle,
    DialogContentText,
    DialogContent,
    DialogActions,
} from '@material-ui/core';

export const FriendRequestDialog = ({ visible, setVisible, message, setMessage, onClick }: any): JSX.Element => {
    return (
        <Dialog open={visible} onClose={(): void => setVisible(false)} aria-labelledby="form-dialog-title">
            <DialogTitle id="form-dialog-title">Friend Request</DialogTitle>
            <DialogContent>
                <DialogContentText>Send a message with the friend request!</DialogContentText>
                <TextField
                    autoFocus
                    margin="dense"
                    id="message"
                    label="Say hello!"
                    type="text"
                    fullWidth
                    onChange={(event: any): void => setMessage(event.target.value)}
                    value={message}
                />
            </DialogContent>
            <DialogActions>
                <Button
                    onClick={(): void => {
                        setVisible(false);
                    }}
                    color="primary"
                >
                    Cancel
                </Button>
                <Button onClick={onClick} color="primary">
                    Send
                </Button>
            </DialogActions>
        </Dialog>
    );
};
