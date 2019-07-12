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
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import lipton from '../../images/lipton.jpg'
import Grid from '@material-ui/core/Grid';
import Button from '@material-ui/core/Button';
import ButtonGroup from '@material-ui/core/ButtonGroup';

const useStyles = makeStyles(theme => ({
  card: {
    maxWidth: 450,
  },
  media: {
    height: 0,
    paddingTop: '56.25%',
  },
  avatar: {
    backgroundColor: red[500],
  },
}));

export const ProductCard = () => {
  const classes = useStyles();

  const user = {
    firstName: "Ville",
    lastName: "Heikkilä"
  }
  const product = {
    id: "asdd",
    name: "Lipton Green Tea",
    producer: "Nestle",
    type: "Virvoitusjuoma",
    subType: "Jäätee",
    date: "March 23, 2019",
    imageURL: "https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg"
  };

  return (
    <div>
      <Card className={classes.card}>
        <CardHeader
          avatar={
            <Avatar aria-label="Product" src="https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg"
              className={classes.avatar}>
              R
          </Avatar>
          }
          action={
            <IconButton aria-label="Settings">
              <MoreVertIcon />
            </IconButton>
          }
          title={`Added by ${user.firstName} ${user.lastName}`}
          subheader={product.date}
        />
        <CardMedia
          className={classes.media}
          image={lipton}
          title="Paella dish"
        />
        <CardContent>
          <Typography variant="h4" color="textSecondary" component="p">
            {product.name}
          </Typography>
          <Typography variant="h5" color="textSecondary" component="p">
            {product.producer}
          </Typography>
          <Typography variant="h5" color="textSecondary" component="p">
            {product.type} {product.subType}
          </Typography>
        </CardContent>
        <Grid item xs={12}>
          <ButtonGroup fullWidth aria-label="Product Actions">
            <Button>Check-in!</Button>
          </ButtonGroup>
        </Grid>
      </Card>
    </div>
  );
};
