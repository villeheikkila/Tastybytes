import { Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle } from '@material-ui/core';
import React from 'react';

interface ConfirmationDialogProps {
    content: string;
    title: string;
    description: string;
    declineButton: string;
    acceptButton: string;
    visible: boolean;
    setVisible: React.Dispatch<React.SetStateAction<boolean>>;
    onAccept: { (onClick: React.MouseEvent<HTMLButtonElement, MouseEvent>): void };
}

export const ConfirmationDialog = ({
    content,
    title,
    description,
    declineButton,
    acceptButton,
    visible,
    setVisible,
    onAccept,
}: ConfirmationDialogProps): JSX.Element => {
    return (
        <Dialog
            open={visible || false}
            onClose={(): void => setVisible(false)}
            aria-labelledby={title}
            aria-describedby={description}
            fullWidth
        >
            <DialogTitle id={title}>{title}</DialogTitle>
            <DialogContent>
                <DialogContentText id={description}>{content}</DialogContentText>
            </DialogContent>

            <DialogActions>
                <Button
                    onClick={(): void => {
                        setVisible(false);
                    }}
                    color="primary"
                >
                    {declineButton}
                </Button>

                <Button onClick={onAccept} color="primary" autoFocus>
                    {acceptButton}
                </Button>
            </DialogActions>
        </Dialog>
    );
};
