import React, { useState } from 'react';
import { IConfirmationDialog } from '../../types'

import DialogActions from '@material-ui/core/DialogActions';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';

export const ConfirmationDialog: React.FC<IConfirmationDialog> = ({ content, title, description, declineButton, acceptButton, value, setValue }) => {
    const [open, setOpen] = useState(true);

    return (
        <div>
            <Dialog
                open={open}
                onClose={() => setOpen(false)}
                aria-labelledby={title}
                aria-describedby={description}
            >
                <DialogTitle id={title}>{title}</DialogTitle>
                <DialogContent>
                    <DialogContentText id={description}>
                        {content}
                    </DialogContentText>
                </DialogContent>

                <DialogActions>
                    <Button onClick={() => {
                        setOpen(false)
                        setValue(false)
                    }} color="primary">
                        {declineButton}
                    </Button>

                    <Button onClick={() => {
                        setOpen(false)
                        setValue(true)
                    }} color="primary" autoFocus>
                        {acceptButton}
                    </Button>
                </DialogActions>
            </Dialog>
        </div>
    );
}