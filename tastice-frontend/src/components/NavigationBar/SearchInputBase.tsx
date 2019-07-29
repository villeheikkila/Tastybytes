import React from 'react';
import SearchIcon from '@material-ui/icons/Search';
import { fade } from '@material-ui/core/styles';
import 'typeface-leckerli-one';

import { makeStyles, InputBase, Theme, createStyles } from '@material-ui/core';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        search: {
            position: 'relative',
            borderRadius: theme.shape.borderRadius,
            backgroundColor: fade(theme.palette.common.white, 0.15),
            '&:hover': {
                backgroundColor: fade(theme.palette.common.white, 0.25),
            },
            marginRight: theme.spacing(2),
            marginLeft: 0,
            width: '100%',
            [theme.breakpoints.up('sm')]: {
                marginLeft: theme.spacing(3),
                width: 'auto',
            },
        },
        searchIcon: {
            width: theme.spacing(7),
            height: '100%',
            position: 'absolute',
            pointerEvents: 'none',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
        },
        inputRoot: {
            color: 'inherit',
        },
        inputInput: {
            padding: theme.spacing(1, 1, 1, 7),
            transition: theme.transitions.create('width'),
            width: '100%',
            [theme.breakpoints.up('md')]: {
                width: 200,
            },
        },
    }),
);

interface SearchInputBaseProps {
    search: string;
    setSearch: React.Dispatch<React.SetStateAction<string>>;
    placeholder: string;
}

export const SearchInputBase = ({ search, setSearch, placeholder }: SearchInputBaseProps): JSX.Element => {
    const classes = useStyles();

    return (
        <div className={classes.search}>
            <div className={classes.searchIcon}>
                <SearchIcon />
            </div>
            <InputBase
                placeholder={placeholder}
                classes={{
                    root: classes.inputRoot,
                    input: classes.inputInput,
                }}
                value={search}
                onChange={({ target }): void => setSearch(target.value)}
                inputProps={{ 'aria-label': 'Search' }}
            />
        </div>
    );
};
