import React from "react";
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardHeader from '@material-ui/core/CardHeader';
import CardMedia from '@material-ui/core/CardMedia';
import CardContent from '@material-ui/core/CardContent';
import Avatar from '@material-ui/core/Avatar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import { red } from '@material-ui/core/colors';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import lipton from '../../images/lipton.jpg'
import Grid from '@material-ui/core/Grid';
import Button from '@material-ui/core/Button';
import ButtonGroup from '@material-ui/core/ButtonGroup';
import { IProduct } from '../../types'

const useStyles = makeStyles(theme => ({
  card: {
    maxWidth: 500,
    margin: `${theme.spacing(3)}px auto`,
  },
  media: {
    height: 0,
    paddingTop: '56.25%',
  },
  avatar: {
    backgroundColor: red[500],
  },
}));

export const ProductCard: React.FC<IProduct> = ({ id, name, producer, type, subType, dateAdded, imgURL, firstName, lastName }) => {
  const classes = useStyles();

  return (
    <div>
      <Card className={classes.card}>
        <CardHeader
          avatar={
            <Avatar aria-label="Product" src={imgURL}
              className={classes.avatar}>
              R
          </Avatar>
          }
          action={
            <IconButton aria-label="Settings">
              <MoreVertIcon />
            </IconButton>
          }
          title={`Added by ${firstName} ${lastName}`}
          subheader={dateAdded}
        />
        <CardMedia
          className={classes.media}
          image={lipton}
          title={name}
        />
        <CardContent>
          <Typography variant="h4" color="textSecondary" component="p">
            {name}
          </Typography>
          <Typography variant="h5" color="textSecondary" component="p">
            {producer}
          </Typography>
          <Typography variant="h5" color="textSecondary" component="p">
            {type} {subType}
          </Typography>
        </CardContent>
        <Grid item xs={12}>
          <ButtonGroup fullWidth aria-label="Check-in!">
            <Button>Check-in!</Button>
          </ButtonGroup>
        </Grid>
      </Card>
    </div>
  );
};
