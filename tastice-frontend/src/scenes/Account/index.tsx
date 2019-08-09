import { useMutation, useQuery } from '@apollo/react-hooks';
import { Button, createStyles, makeStyles, Paper, Theme, Typography } from '@material-ui/core';
import { deleteFromStorage } from '@rehooks/local-storage';
import React, { useState } from 'react';
import useReactRouter from 'use-react-router';
import { ConfirmationDialog } from '../../components/ConfirmationDialog';
import { DELETE_USER, ME } from '../../graphql';
import { client } from '../../index';
import { errorHandler } from '../../utils';
import { AccountAvatar } from './AccountAvatar';
import { PasswordForm } from './PasswordForm';
import { UserForm } from './UserForm';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        paper: {
            marginTop: 30,
            maxWidth: 700,
            padding: theme.spacing(3, 2),
            margin: `${theme.spacing(1)}px auto`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            alignContent: 'center',
        },
        title: {
            marginTop: 10,
        },
        button: {
            marginTop: 15,
            width: '30%',
        },
    }),
);

export const Account = (): JSX.Element | null => {
    const classes = useStyles();
    const [visible, setVisible] = useState(false);

    const { data } = useQuery(ME);
    const { me } = data;
    const { history } = useReactRouter();

    const [deleteUser] = useMutation(DELETE_USER, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }],
    });

    if (me === undefined) {
        return null;
    }

    const handleDeleteUser = async (): Promise<void> => {
        setVisible(false);
        await deleteUser({
            variables: { id: me.id },
        });
        await client.clearStore();
        deleteFromStorage('user');
        history.push('/');
    };

    return (
        <>
            <Paper className={classes.paper}>
                <Typography variant="h4" component="h3" className={classes.title}>
                    Edit Profile Settings
                </Typography>

                <AccountAvatar user={me} />
                <UserForm user={me} />
                <PasswordForm id={me} />

                <Button
                    variant="outlined"
                    color="secondary"
                    className={classes.button}
                    onClick={(): void => setVisible(true)}
                >
                    Delete User
                </Button>
            </Paper>

            <ConfirmationDialog
                visible={visible}
                setVisible={setVisible}
                description={'hei'}
                title={'Warning!'}
                content={'Are you sure you want to remove your account?'}
                onAccept={handleDeleteUser}
                declineButton={'Cancel'}
                acceptButton={'Yes'}
            />
        </>
    );
};
