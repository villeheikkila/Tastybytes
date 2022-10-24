import {
    Button,
    Dialog,
    DialogActions,
    DialogContent,
    DialogContentText,
    DialogTitle,
    TextField,
} from '@material-ui/core';
import React from 'react';

interface FriendRequestDialogProps {
    visible: boolean;
    message: string;
    setVisible: React.Dispatch<React.SetStateAction<boolean>>;
    setMessage: React.Dispatch<React.SetStateAction<string>>;
    onClick: { (onClick: React.MouseEvent<HTMLButtonElement, MouseEvent>): void };
}

export const FriendRequestDialog = ({
    visible,
    setVisible,
    message,
    setMessage,
    onClick,
}: FriendRequestDialogProps): JSX.Element => {
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
                    onChange={(event): void => setMessage(event.target.value)}
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
