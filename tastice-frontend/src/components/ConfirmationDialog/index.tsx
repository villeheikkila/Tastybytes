import React from 'react';
import { ConfirmationDialogProps } from '../../types';

import { Dialog, DialogContent, DialogTitle, DialogContentText, Button, DialogActions } from '@material-ui/core';

export const ConfirmationDialog: React.FC<ConfirmationDialogProps> = ({
    content,
    title,
    description,
    declineButton,
    acceptButton,
    visible,
    setVisible,
    onAccept,
}) => {
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
