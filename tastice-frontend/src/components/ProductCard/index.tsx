import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import Card from "@material-ui/core/Card";
import CardContent from "@material-ui/core/CardContent";
import Avatar from "@material-ui/core/Avatar";
import IconButton from "@material-ui/core/IconButton";
import Typography from "@material-ui/core/Typography";
import DoneOutline from "@material-ui/icons/DoneOutline";
import lipton from "../../images/lipton.jpg";
import Link from "@material-ui/core/Link";
import { Link as RouterLink } from "react-router-dom";
import { IProductCard } from "../../types";
import CardActionArea from '@material-ui/core/CardActionArea';
import history from "../../utils/history";

const useStyles = makeStyles(theme => ({
  card: {
    maxWidth: 700,
    margin: `${theme.spacing(1)}px auto`,
    display: 'flex',

  },
  actionArea: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: "left"
  },
  picture: {
    margin: 10,
    width: 100,
    height: 100
  },
  details: {
    display: 'flex',
    flexDirection: 'column',
    paddingLeft: theme.spacing(1),
    paddingBottom: theme.spacing(1),
  }
}));

export const ProductCard: React.FC<IProductCard> = ({ product }) => {
  const classes = useStyles();
  const { id, name, producer, category, subCategory } = product;
  return (
    <Card className={classes.card}>
      <CardActionArea onClick={() => history.push(`/product/${id}`)} className={classes.actionArea} >
        <Avatar alt="Image" src={lipton} className={classes.picture} />
        <div className={classes.details}>
          <CardContent >
            <Typography variant="h5" color="textSecondary" component="p">
              <Link
                component={RouterLink}
                to={`/product/${id}`}
              >
                {name}
              </Link>
            </Typography>
            <Typography variant="h6" color="textSecondary" component="p">
              {producer}
            </Typography>
            <Typography variant="h6" color="textSecondary" component="p">
              {category} {subCategory}
            </Typography>
          </CardContent>
        </div>
      </CardActionArea>
    </Card >
  );
};
