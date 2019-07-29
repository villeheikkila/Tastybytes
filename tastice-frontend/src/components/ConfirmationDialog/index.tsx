import React from 'react';

import { Dialog, DialogContent, DialogTitle, DialogContentText, Button, DialogActions } from '@material-ui/core';

interface ConfirmationDialogProps {
    content: string;
    title: string;
    description: string;
    declineButton: string;
    acceptButton: string;
    visible: boolean;
    setVisible: any;
    onAccept: any;
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
        <div>
            <Dialog
                open={visible || false}
                onClose={(): void => setVisible(false)}
                aria-labelledby={title}
                aria-describedby={description}
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
        </div>
    );
};
