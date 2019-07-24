import React, { useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import { usePopupState, bindTrigger, bindMenu } from 'material-ui-popup-state/hooks';
import Rating from 'material-ui-rating';
import { blue } from '@material-ui/core/colors';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import { ProductCard } from '../ProductCard';
import { EditCheckIn } from '../EditCheckIn';
import { useMutation, useQuery } from '@apollo/react-hooks';
import { DELETE_CHECKIN, ALL_CHECKINS } from '../../queries';
import { errorHandler } from '../../utils';
import { ConfirmationDialog } from '../ConfirmationDialog';
import { CheckInContent } from '../CheckInContent';

import { Link, Typography, IconButton, Avatar, CardHeader, Card, makeStyles, Menu, MenuItem } from '@material-ui/core';

const useStyles = makeStyles(theme => ({
    card: {
        maxWidth: 700,
        margin: `${theme.spacing(1)}px auto`,
    },
    media: {
        paddingTop: '56.25%',
    },
    avatar: {
        backgroundColor: blue[500],
    },
}));

const months: any = {
    0: 'January',
    1: 'February',
    2: 'March',
    3: 'April',
    4: 'May',
    5: 'June',
    6: 'July',
    7: 'August',
    8: 'September',
    9: 'October',
    10: 'November',
    11: 'December',
};

export const CheckInCard: React.FC<any> = ({ checkin, showProduct }) => {
    const classes = useStyles();
    const [visible, setVisible] = useState();
    const [openEdit, setOpenEdit] = useState();
    const menuState = usePopupState({ variant: 'popover', popupId: 'CheckInMenu' });
    const [deleteCheckin] = useMutation(DELETE_CHECKIN, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_CHECKINS }],
    });

    const checkinObject = {
        authorFirstName: checkin.author.firstName,
        authorLastName: checkin.author.lastName,
        authorId: checkin.author.id,
        comment: checkin.comment,
        rating: checkin.rating,
        name: checkin.product.name,
        id: checkin.product.id,
        checkinId: checkin.id,
        producer: checkin.product.producer,
        date: new Date(checkin.createdAt),
    };

    const productObject = {
        name: checkin.product.name,
        id: checkin.product.id,
        producer: checkin.product.producer,
        category: checkin.product.category,
        subCategory: checkin.product.subCategory,
    };

    const handleDeleteCheckin = async () => {
        const response = await deleteCheckin({
            variables: { id: checkinObject.checkinId },
        });
        console.log('response: ', response);
    };

    return (
        <div>
            <Card className={classes.card}>
                <CardHeader
                    avatar={
                        <Avatar aria-label="Author" src={''} className={classes.avatar}>
                            R
                        </Avatar>
                    }
                    action={
                        <IconButton aria-label="Settings" {...bindTrigger(menuState)}>
                            <MoreVertIcon />
                        </IconButton>
                    }
                    title={
                        <Typography variant="h6" color="textSecondary" component="p">
                            <Link component={RouterLink} to={`/user/${checkinObject.authorId}`}>
                                {checkinObject.authorFirstName} {checkinObject.authorLastName}
                            </Link>
                        </Typography>
                    }
                    subheader={`${checkinObject.date.getDate()} ${
                        months[checkinObject.date.getMonth()]
                    }, ${checkinObject.date.getFullYear()}
          `}
                />

                {showProduct && <ProductCard product={productObject} />}

                {openEdit ? (
                    <EditCheckIn id={checkinObject.checkinId} setOpenEdit={setOpenEdit} />
                ) : (
                    <CheckInContent rating={checkinObject.rating} comment={checkinObject.comment} />
                )}
            </Card>

            <Menu {...bindMenu(menuState)}>
                <MenuItem
                    onClick={() => {
                        setOpenEdit(true);
                        menuState.close();
                    }}
                >
                    Edit Check-in
                </MenuItem>
                <MenuItem
                    onClick={() => {
                        setVisible(true);
                        menuState.close();
                    }}
                >
                    Remove Check-in
                </MenuItem>
            </Menu>

            <ConfirmationDialog
                visible={visible}
                setVisible={setVisible}
                description={'HEEII'}
                title={'Warning!'}
                content={`Are you sure you want to remove checkin for '${productObject.name}'`}
                onAccept={handleDeleteCheckin}
                declineButton={'Cancel'}
                acceptButton={'Yes'}
            />
        </div>
    );
};
