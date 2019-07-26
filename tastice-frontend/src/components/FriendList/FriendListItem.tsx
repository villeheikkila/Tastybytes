import React, { useState } from 'react';

import {
    createStyles,
    Theme,
    makeStyles,
    ListItemText,
    Divider,
    Typography,
    ListItemAvatar,
    Avatar,
    List,
    ListItem,
} from '@material-ui/core';

export const FriendListItem: React.FC<any> = ({ user }) => {
    const { firstName, lastName, id } = user;

    return (
        <ListItem button alignItems="flex-start" key={id}>
            <ListItemAvatar>
                <Avatar
                    alt={firstName}
                    src="https://cdn1.thr.com/sites/default/files/imagecache/scale_crop_768_433/2019/03/avatar-publicity_still-h_2019.jpg"
                />
            </ListItemAvatar>
            <ListItemText primary={`${firstName} ${lastName}`} />
        </ListItem>
    );
};
