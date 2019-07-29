import React from 'react';

import { Dialog, DialogContent, DialogTitle, DialogContentText, Button, DialogActions } from '@material-ui/core';

export const ConfirmationDialog = ({
    content,
    title,
    description,
    declineButton,
    acceptButton,
    visible,
    setVisible,
    onAccept,
}: ConfirmationDialogProps) => {
    return (
        <div>
            <Dialog
                open={visible || false}
                onClose={() => setVisible(false)}
                aria-labelledby={title}
                aria-describedby={description}
            >
                <DialogTitle id={title}>{title}</DialogTitle>
                <DialogContent>
                    <DialogContentText id={description}>{content}</DialogContentText>
                </DialogContent>

                <DialogActions>
                    <Button
                        onClick={() => {
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
